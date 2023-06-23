import json
import os
import openai
import boto3

openai.api_key = os.environ['API_Key']
API_ENDPOINT = os.environ['API_ENDPOINT']

def lambda_handler(event, context):
    # sourceIp の値を取得
    sourceIp = event['requestContext']['http']['sourceIp']
    
    #DynamoDB 過去履歴確認
    # dynamodb_search(sourceIp)

    # OpenAI API にリクエスト
    input_text = event['queryStringParameters']['input_text']
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": input_text}, 
        ]
    )

    # DynamoDB 履歴更新
    dynamodb_add(sourceIp,response)
    
    # レスポンス
    return {
        'statusCode': 200,
        'body': response["choices"][0]["message"]["content"],
        'isBase64Encoded': False,
        'headers':{}
    }

# DynamoDBへの追加を行う関数
def dynamodb_add(sourceIp, response):
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