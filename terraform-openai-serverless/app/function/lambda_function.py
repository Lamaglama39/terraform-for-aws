import json
import os
import openai
import boto3
from botocore.exceptions import ClientError

openai.api_key = os.environ['API_Key']
API_ENDPOINT = os.environ['API_ENDPOINT']

def lambda_handler(event, context):
    new_text = event['queryStringParameters']['input_text']
    sourceIp = event['requestContext']['http']['sourceIp']
    
    # DynamoDBから過去の会話を取得
    conversation = dynamodb_search(new_text, sourceIp)

    # 新しいメッセージを会話に追加
    conversation.append({"role": "user", "content": event['queryStringParameters']['input_text']})

    # OpenAI APIにリクエスト
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
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
        'isBase64Encoded': False,
        'headers': {}
    }


def dynamodb_search(new_text, sourceIp):
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
        return [{"role": "system", "content": new_text}]

    if 'Item' in response:
        return json.loads(response['Item']['conversation'])
    else:
        return [{"role": "system", "content": new_text}]


def dynamodb_add(sourceIp, conversation):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('openai-table')
    table.put_item(
        Item={
            'sourceIp': sourceIp,
            'conversation': json.dumps(conversation)
        }
    )