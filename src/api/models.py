import ipaddress

from typing import List
from pydantic import BaseModel, Field
from pydantic import validator


class Subnet(BaseModel):

    cidr: str = Field(
        ...,
        example="10.0.1.0/24"
    )

    az: str = Field(
        ...,
        example="ap-south-1a"
    )

    @validator("cidr")
    def validate_cidr(cls, value):

        try:
            ipaddress.ip_network(value)

        except ValueError:

            raise ValueError(
                "Invalid CIDR format"
            )

        return value


class CreateVpcRequest(BaseModel):

    vpc_cidr: str = Field(
        ...,
        example="10.0.0.0/16"
    )

    public_subnets: List[Subnet]

    private_subnets: List[Subnet]

    @validator("vpc_cidr")
    def validate_vpc_cidr(cls, value):

        try:
            ipaddress.ip_network(value)

        except ValueError:

            raise ValueError(
                "Invalid VPC CIDR format"
            )

        return value