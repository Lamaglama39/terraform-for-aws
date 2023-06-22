from decimal import Decimal
import json
import os
import openai

openai.api_key = os.environ['API_Key']
API_ENDPOINT = os.environ['API_ENDPOINT']

def decimal_to_int(obj):
    if isinstance(obj, Decimal):
        return int(obj)

def lambda_handler(event, context):
    input_text = event['queryStringParameters']['input_text']
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": input_text}, 
        ]
    )
    return {
        'statusCode': 200,
        'body': response["choices"][0]["message"]["content"],
        'isBase64Encoded': False,
        'headers':{}
    }
    