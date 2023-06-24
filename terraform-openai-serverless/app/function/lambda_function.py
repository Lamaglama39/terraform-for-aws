import json
import os
import openai
import boto3
from botocore.exceptions import ClientError

openai.api_key = os.environ['API_Key']
API_ENDPOINT = os.environ['API_ENDPOINT']

def lambda_handler(event, context):
    
    #DynamoDB 過去履歴確認
    input_text = dynamodb_search(event)
    
    # OpenAI API にリクエスト
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": input_text}, 
        ]
    )

    # DynamoDB 履歴更新
    dynamodb_add(event,response)
    
    # レスポンス
    return {
        'statusCode': 200,
        'body': response["choices"][0]["message"]["content"],
        'isBase64Encoded': False,
        'headers':{}
    }


# DynamoDBからの検索を行う関数
def dynamodb_search(event):
    sourceIp = event['requestContext']['http']['sourceIp']
    
    # DynamoDB オブジェクトを作成
    dynamodb = boto3.resource('dynamodb')

    # DynamoDBのテーブル名
    table = dynamodb.Table('openai-table')

    try:
        # sourceIpと一致する項目の検索
        response = table.get_item(
            Key={
                'sourceIp': sourceIp
            }
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
        # エラー時は今回のリクエストのテキストを返す
        return event['queryStringParameters']['input_text']

    # 項目が存在すれば、その内容を返す
    if 'Item' in response:
        return response['Item']['response']
    else:
        # 項目が存在しなければ今回のリクエストのテキストを返す
        return event['queryStringParameters']['input_text']


# DynamoDBへの追加を行う関数
def dynamodb_add(event, response):
    sourceIp = event['requestContext']['http']['sourceIp']
    # DynamoDB オブジェクトを作成
    dynamodb = boto3.resource('dynamodb')
    
    # DynamoDBのテーブル名
    table = dynamodb.Table('openai-table')
    
    # responseはOpenAIからの応答なので、Pythonの辞書型オブジェクト
    # DynamoDBは数値、文字列、辞書型など特定のデータタイプしか受け入れないため、必要に応じてjson.dumps()等を用いて適切な形式に変換する
    # 応答をそのままJSON文字列に変換して格納する
    response_str = json.dumps(response)
    
    # DynamoDBに追加
    table.put_item(
        Item={
            'sourceIp': sourceIp,
            'response': response_str
        }
    )