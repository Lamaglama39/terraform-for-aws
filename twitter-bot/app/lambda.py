import json
import random
import boto3
import tweepy
import os
from datetime import datetime, timedelta, timezone
JST = timezone(timedelta(hours=+9), 'JST')

def handler(event, context):
    contents = random_choice_text()
    tweet(contents)

    return {
        'statusCode': 200,
        'body': json.dumps('SUCCESS'),
        'date': datetime.now(JST).strftime('%Y-%m-%d %H:%M:%S'),
        'contents': contents
    }

def tweet(contents: str):
    ck = os.environ['api_key']
    cs = os.environ['api_secret_key']
    at = os.environ['acces_token']
    ats = os.environ['acces_token_secrete']
    
    client = tweepy.Client(consumer_key=ck, consumer_secret=cs, access_token=at, access_token_secret=ats)
    client.create_tweet(text = contents)

def random_choice_text() -> str:
    db = boto3.resource('dynamodb')
    table = db.Table(os.environ['dynamodb_name'])
    res = table.scan()
    items = res['Items']
    
    now = datetime.now(JST).strftime('%Y/%m/%d %H:%M:%S')
    texts = []
    weights = []
    for item in items:
        texts.append(item['contents'] +'\n'+ item['description'] +'\n'+'\n'+'('+now+')')
        weights.append(int(item['weight']))
    return random.choices(texts, k = 1, weights=weights)[0]