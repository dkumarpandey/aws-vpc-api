import boto3
import os

dynamodb = boto3.resource("dynamodb")

table = dynamodb.Table(
    os.environ["TABLE_NAME"]
)


def save_vpc(data):
    table.put_item(Item=data)


def get_vpc(vpc_id):
    response = table.get_item(
        Key={"vpc_id": vpc_id}
    )

    return response.get("Item")