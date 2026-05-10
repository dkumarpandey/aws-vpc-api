from typing import List
from pydantic import BaseModel, Field


class Subnet(BaseModel):
    cidr: str = Field(..., example="10.0.1.0/24")
    az: str = Field(..., example="ap-south-1a")


class CreateVpcRequest(BaseModel):
    vpc_cidr: str = Field(..., example="10.0.0.0/16")
    public_subnets: List[Subnet]
    private_subnets: List[Subnet]