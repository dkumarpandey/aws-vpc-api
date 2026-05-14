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

        deleted_subnets = []

        if subnets:

            for subnet in subnets:

                subnet_id = subnet.get("subnet_id")

                if not subnet_id:
                    continue

                logger.info(
                    f"Deleting subnet {subnet_id}"
                )

                ec2.delete_subnet(
                    SubnetId=subnet_id
                )

                deleted_subnets.append(subnet_id)

        if vpc_id:

            logger.info(
                f"Deleting VPC {vpc_id}"
            )

            ec2.delete_vpc(
                VpcId=vpc_id
            )

        return {
            "status": "SUCCESS",
            "deleted_vpc_id": vpc_id,
            "deleted_subnets": deleted_subnets
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