import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        filename = record['s3']['object']['key']
        logger.info(f"Image received: {filename} from bucket: {bucket}")
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }
