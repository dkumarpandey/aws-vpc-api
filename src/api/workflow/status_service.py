import boto3
import os

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TABLE_NAME"]

def get_status(request_id):

    table = dynamodb.Table(TABLE_NAME)

    response = table.get_item(
        Key={
            "request_id": request_id
        }
    )

    item = response.get("Item")

    if not item:
        return {
            "status": "NOT_FOUND",
            "message": f"Request {request_id} not found"
        }

    return item