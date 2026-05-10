import boto3
from datetime import datetime

ec2 = boto3.client("ec2")


def create_vpc(payload):

    vpc_response = ec2.create_vpc(
        CidrBlock=payload["vpc_cidr"]
    )

    vpc_id = vpc_response["Vpc"]["VpcId"]

    public_subnet_ids = []

    for subnet in payload["public_subnets"]:

        subnet_response = ec2.create_subnet(
            VpcId=vpc_id,
            CidrBlock=subnet["cidr"],
            AvailabilityZone=subnet["az"]
        )

        public_subnet_ids.append(
            subnet_response["Subnet"]["SubnetId"]
        )

    private_subnet_ids = []

    for subnet in payload["private_subnets"]:

        subnet_response = ec2.create_subnet(
            VpcId=vpc_id,
            CidrBlock=subnet["cidr"],
            AvailabilityZone=subnet["az"]
        )

        private_subnet_ids.append(
            subnet_response["Subnet"]["SubnetId"]
        )

    return {
        "vpc_id": vpc_id,
        "vpc_cidr": payload["vpc_cidr"],
        "public_subnets": public_subnet_ids,
        "private_subnets": private_subnet_ids,
        "created_at": datetime.utcnow().isoformat()
    }