import os
import json
import uuid
import boto3
from datetime import datetime

stepfunctions = boto3.client("stepfunctions")
dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TABLE_NAME"]
STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

def start_provisioning(payload):

    request_id = str(uuid.uuid4())

    table = dynamodb.Table(TABLE_NAME)

    table.put_item(
        Item={
            "request_id": request_id,
            "status": "IN_PROGRESS",
            "created_at": datetime.utcnow().isoformat()
        }
    )
    
    subnets = []

    for subnet in payload.get("public_subnets", []):

        subnet["type"] = "public"

        subnet["availability_zone"] = subnet.pop("az")

        subnet["name"] = (
            f"public-{subnet['cidr']}"
        )

        subnets.append(subnet)

    for subnet in payload.get("private_subnets", []):

        subnet["type"] = "private"

        subnet["availability_zone"] = subnet.pop("az")

        subnet["name"] = (
            f"private-{subnet['cidr']}"
        )

        subnets.append(subnet)    

    
    workflow_payload = {
        "vpc_cidr": payload["vpc_cidr"],
        "subnets": subnets
    }
    
    stepfunctions.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        name=request_id,
        input=json.dumps({
            "request_id": request_id,
            "payload": workflow_payload
        })
    )

    return {
        "request_id": request_id,
        "status": "IN_PROGRESS"
    }