import psycopg2
import os
import boto3
import botocore

# Simple Python script for testing if our Lambda function can read from S3 and RDS
# ENV VARS:
# DB_HOST - RDS host
# DB_NAME - RDS database name
# DB_USER - RDS username
# DB_PASS - RDS password

def handler(event, context):
    print("Received event: " + str(event))
    print("Received context: " + str(context))

    # If the path specifies 's3', return the content of STATIC_URL/test.html
    if 's3' in event['path']:
        client = boto3.client('s3', os.environ['AWS_REGION'], config=botocore.config.Config(s3={'addressing_style':'path'}))
        response = client.get_object(Bucket=os.environ['STATIC_URL'], Key=os.environ['APP_VERSION'] + 'test.html')
        body = response['Body'].read().decode('utf-8')
    # Else if the path specifies 'rds', check the connection to RDS
    elif 'rds' in event['path']:
        conn = psycopg2.connect(
            host=os.environ['DB_HOST'],
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASS']
        )
        if conn:
            body = 'Connection to RDS successful'
        else:
            body = 'Connection to RDS failed'
    else:
        body = 'Invalid path'

    return {
        'statusCode': 200,
        'body': body
    }
