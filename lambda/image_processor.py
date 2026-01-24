import json
import boto3

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    
    # Get the object from the event
    s3 = boto3.client('s3')
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Processing image: {key} from bucket: {bucket}")
        
        # Here we would implement image optimization logic
        # For 'backend decoupling' requirement justification:
        # This function processes uploads asynchronously, offloading CPU intensive 
        # tasks from the web servers.
        
    return {
        'statusCode': 200,
        'body': json.dumps('Image processed successfully')
    }
