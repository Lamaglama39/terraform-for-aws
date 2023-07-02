import json
import os
import openai
import boto3
from botocore.exceptions import ClientError
import time

openai.api_key = os.environ['API_Key']
API_ENDPOINT = os.environ['API_ENDPOINT']

# Lambda関数
def lambda_handler(event, context):
    #クエリパラメータ
    api_model = event['queryStringParameters'].get('api_model', 'gpt-3.5-turbo')
    system_text = event['queryStringParameters'].get('system_text', 'Chat with OpenAI started.')
    user_text = event['queryStringParameters']['user_text']
    sourceIp = event['requestContext']['http']['sourceIp']
    
    # DynamoDBから過去の会話を取得
    conversation = dynamodb_search(sourceIp)

    # 初回利用の場合はsystem messageを追加
    if len(conversation) == 0:
        conversation.append({"role": "system", "content": system_text})

    # 新しいメッセージを会話に追加
    conversation.append({"role": "user", "content": user_text})

    # OpenAI APIにリクエスト
    response = openai.ChatCompletion.create(
        model=api_model,
        messages=conversation
    )

    # APIからの応答を会話に追加
    conversation.append({"role": "assistant", "content": response["choices"][0]["message"]["content"]})

    # DynamoDBの会話を更新
    dynamodb_add(sourceIp, conversation)
    
    # レスポンス
    return {
        'statusCode': 200,
        'body': response["choices"][0]["message"]["content"],
        'isBase64Encoded': False
    }


# DynamoDB検索 関数
def dynamodb_search(sourceIp):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('openai-table')
    
    try:
        response = table.get_item(
            Key={
                'sourceIp': sourceIp
            }
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
        return []
    
    if 'Item' in response:
        return json.loads(response['Item']['conversation'])
    else:
        return []


# 文字数制限 確認関数
def truncate_conversation(conversation):
    token_count = sum([len(c['content']) for c in conversation])
    while token_count > 4096:
        removed_message = conversation.pop(0)
        token_count -= len(removed_message['content'])
    return conversation


# DynamoDB記録 関数
def dynamodb_add(sourceIp, conversation,):
    # TTL用の現在時刻+30分の時刻
    timeout = int(time.time() + 1800)

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('openai-table')
    table.put_item(
        Item={
            'sourceIp': sourceIp,
            'conversation': json.dumps(conversation, ensure_ascii=False),
            'Timeout': timeout
        }
    )