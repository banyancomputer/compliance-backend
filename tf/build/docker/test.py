def handler(event, context):
   # Return a simple response to the thing that triggered the Lambda
   return {
     "statusCode": 200,
     "body": "Hello from Lambda!"
   }
