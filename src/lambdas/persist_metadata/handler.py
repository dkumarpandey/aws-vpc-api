import os
import uuid
import logging
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TABLE_NAME"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):

    try:

        request_id = event.get(
            "request_id",
            str(uuid.uuid4())
        )

                
        status = event.get("status")

        if not status:
            raise ValueError("status is required")

        vpc_id = event.get("vpc_id")

        subnets = event.get("subnets", [])

        created_at = datetime.utcnow().isoformat()

        item = {
            "request_id": request_id,
            "status": status,
            "vpc_id": vpc_id,
            "subnets": subnets,
            "created_at": created_at
        }

        logger.info(
            f"Persisting metadata for request {request_id}"
        )

        table.put_item(
            Item=item
        )

        return {
            "status": "SUCCESS",
            "request_id": request_id,
            "message": "Provisioning metadata persisted"
        }

    except ClientError as e:

        logger.error(str(e))

        return {
            "status": "FAILED",
            "error": str(e)
        }

    except Exception as e:

        logger.error(str(e))

        return {
            "status": "FAILED",
            "error": str(e)
        }