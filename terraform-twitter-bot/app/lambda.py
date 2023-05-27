import json
import random
import boto3
import tweepy
import os
from datetime import datetime, timedelta, timezone
JST = timezone(timedelta(hours=+9), 'JST')

def handler(event, context):
    text = random_choice_text()
    tweet(text)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

def tweet(text: str):
    api_key = os.environ['api_key']
    api_secret_key = os.environ['api_secret_key']
    acces_token = os.environ['acces_token']
    acces_token_secrete = os.environ['acces_token_secrete']
    auth = tweepy.OAuthHandler(api_key, api_secret_key)
    auth.set_access_token(acces_token, acces_token_secrete)
    api = tweepy.API(auth)
    api.update_status(text)

def random_choice_text() -> str:
    db = boto3.resource('dynamodb')
    table = db.Table('yadon')
    res = table.scan()
    items = res['Items']
    
    now = datetime.now(JST).strftime('%Y/%m/%d %H:%M:%S')
    texts = []
    weights = []
    for item in items:
        texts.append(item['text']+'\n'+'\n'+'('+now+')')
        weights.append(int(item['weight']))
    return random.choices(texts, k = 1, weights=weights)[0]