import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")


def lambda_handler(event, context):

    try:

        vpc_id = event.get("vpc_id")

        subnets = event.get("subnets", [])


        if not vpc_id:
            raise ValueError("vpc_id is required")

        if not subnets:
            raise ValueError("subnets list is required")

        created_subnets = []

        for subnet in subnets:

            name = subnet.get("name")

            cidr = subnet.get("cidr")

            availability_zone = subnet.get(
                "availability_zone"
            )

            subnet_type = subnet.get(
                "type",
                "private"
            )

            if not cidr:
                raise ValueError(
                    "Subnet cidr is required"
                )

            if not availability_zone:
                raise ValueError(
                    "availability_zone is required"
                )

            logger.info(
                f"Creating {subnet_type} subnet "
                f"{cidr} in {availability_zone}"
            )

            response = ec2.create_subnet(
                VpcId=vpc_id,
                CidrBlock=cidr,
                AvailabilityZone=availability_zone
            )

            subnet_id = response["Subnet"]["SubnetId"]

            ec2.create_tags(
                Resources=[subnet_id],
                Tags=[
                    {
                        "Key": "Name",
                        "Value": name or f"subnet-{cidr}"
                    },
                    {
                        "Key": "SubnetType",
                        "Value": subnet_type
                    },
                    {
                        "Key": "ManagedBy",
                        "Value": "aws-vpc-api"
                    }
                ]
            )

            created_subnets.append({
                "subnet_id": subnet_id,
                "name": name,
                "cidr": cidr,
                "availability_zone": availability_zone,
                "type": subnet_type
            })

            logger.info(
                f"Created subnet {subnet_id}"
            )

        return {
            "status": "SUCCESS",
            "vpc_id": vpc_id,
            "request_id": event.get("request_id"),
            "subnets": created_subnets
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