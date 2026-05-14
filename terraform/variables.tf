variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "aws-vpc-api"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.11"
}

variable "common_tags" {
  type = map(string)

  default = {
    Project   = "aws-vpc-api"
    ManagedBy = "Terraform"
  }
}