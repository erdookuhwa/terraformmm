import boto3
import os
import json

def lambda_handler(event, context):
    # Create the DynamoDB Object
    ddb = boto3.resource("dynamodb")
    table = ddb.Table(os.environ['TABLE_NAME'])

    # Get current visit count
    response = table.get_item(Key={"user_id": 1, "timestamp": 1})
    item = response.get("Item", {})
    count = item.get("count", 0)

    # Increment count
    count += 1

    # Increment visitor count
    table.put_item(Item={"user_id": 1, "timestamp": 1, "count": count})
    
	# Get item from table after put
    table.get_item(Key={"user_id": 1, "timestamp": 1})

    return {
        'statusCode': 200,
        'body': json.dumps(str(count))
    }