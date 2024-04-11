import boto3
import os
import json
import requests
from datetime import datetime, timedelta, timezone
JST = timezone(timedelta(hours=+9), 'JST')

# メイン関数
def handler(event, context):
    datetask = daily_text()
    weekdaytask = weekday_text()
    line_send("\n".join(datetask))
    line_send("\n".join(weekdaytask))

    ## Lambda成功時のログ
    return {
        'statusCode': 200,
        'body': json.dumps('SUCCESS'),
        'date': datetime.now(JST).strftime('%Y-%m-%d %H:%M:%S'),
        'daymessage': datetask,
        'weekdaymessage': weekdaytask
    }

# Lineへの送信処理
def line_send(text: str):
    ## Lineクレデンシャル情報
    api_url = os.environ['api_url']
    token_event = os.environ['token_event']
    user_id = os.environ['user_id']
    message = text

    ## messageが空なら処理終了
    if not message:
        return

    ## 送信内容の設定
    payload = {
        'to': user_id,
        'messages': [
            {'type': 'text', 'text': message}
        ]
    }
    headers = {
        'Authorization': f'Bearer {token_event}',
        'Content-Type': 'application/json'
    }

    ## 送信処理
    response = requests.post(api_url, headers=headers, data=json.dumps(payload))
    return response

# dynamoDBから特定の日時のメッセージを取得
def daily_text() -> str:
    ## DynamoDBクライアントの作成
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['table_name_day']
    ## 実行日を取得
    today = datetime.now(JST).day

    ## DynamoDBから実行日と合致するメッセージを取得
    table = dynamodb.Table(table_name)
    scan_kwargs = {
        'FilterExpression': boto3.dynamodb.conditions.Attr('day').eq(today),
    }
    response = table.scan(**scan_kwargs)

    ## メッセージをdatetask配列に格納
    datetask = []
    for item in response['Items']:
        datetask.append(item['text'])
    return datetask

# dynamoDBから特定の曜日のメッセージを取得
def weekday_text() -> str:
    ## DynamoDBクライアントの作成
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['table_name_week']
    ## 実行日の曜日を取得
    week_list = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日']
    weekday = datetime.now(JST).weekday()
    weektoday = week_list[weekday]

    ## DynamoDBから実行日と合致するメッセージを取得
    table = dynamodb.Table(table_name)
    scan_kwargs = {
        'FilterExpression': boto3.dynamodb.conditions.Attr('week').eq(weektoday),
    }
    response = table.scan(**scan_kwargs)

    ## メッセージをweekdaytask配列に格納
    weekdaytask = []
    for item in response['Items']:
        weekdaytask.append(item['text'])
    return weekdaytask