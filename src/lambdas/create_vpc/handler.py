import json
import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client("ec2")


def lambda_handler(event, context):

    try:

        payload = event.get("payload", {})

        vpc_cidr = payload.get("vpc_cidr")

        if not vpc_cidr:
            raise ValueError("vpc_cidr is required")

        response = ec2.create_vpc(
            CidrBlock=vpc_cidr
        )

        vpc_id = response["Vpc"]["VpcId"]

        ec2.create_tags(
            Resources=[vpc_id],
            Tags=[
                {
                    "Key": "Name",
                    "Value": "aws-vpc-api"
                },
                {
                    "Key": "ManagedBy",
                    "Value": "Terraform"
                }
            ]
        )


        
        return {
            "status": "SUCCESS",
            "request_id": event.get("request_id"),
            "vpc_id": vpc_id,
            "vpc_cidr": vpc_cidr,
            "subnets": payload.get("subnets", [])
        }

    except ClientError as e:

        return {
            "status": "FAILED",
            "error": str(e)
        }

    except Exception as e:

        return {
            "status": "FAILED",
            "error": str(e)
        }