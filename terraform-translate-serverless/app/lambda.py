import os
import json
import boto3
import datetime

translate = boto3.client('translate')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['table_name'])

def handler(event, context):
    input_text = event['queryStringParameters']['input_text']
    response = translate.translate_text(
        Text=input_text,
        SourceLanguageCode='ja',
        TargetLanguageCode='en'
    )
    output_text = response.get('TranslatedText')
    table.put_item(
        Item = {
            'timestamp': datetime.datetime.now().strftime("%Y%m%d%H%M%S"),
            'input_text': input_text,
            'output_text': output_text
        }
        )
    return {
        'statusCode': 200,
        'body': json.dumps({
            'output_text':output_text
        }),
        'isBase64Encoded': False,
        'headers':{}
    }