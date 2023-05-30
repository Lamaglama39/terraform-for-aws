import os
import json
import boto3
import datetime
import logging

translate = boto3.client('translate')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['table_name'])

def handler(event, context):
    input_text = event['queryStringParameters']['input_text']
    
    try:
        response = translate.translate_text(
        Text=input_text,
        SourceLanguageCode='ja',
        TargetLanguageCode='en'
    )
    except Exception as e:
        logging.error(e.response['Error']['Message'])
        raise Exception("[ErrorMessage]: " + str(e))
    
    output_text = response.get('TranslatedText')

    try:
        table.put_item(
        Item = {
            'timestamp': datetime.datetime.now().strftime("%Y%m%d%H%M%S"),
            'input_text': input_text,
            'output_text': output_text
        }
        )
    except Exception as e:
        logging.error(e.response['Error']['Message'])
        raise Exception("[ErrorMessage]: " + str(e))

    return {
        'statusCode': 200,
        'body': json.dumps({
            'output_text':output_text
        }),
        'isBase64Encoded': False,
        'headers':{}
    }