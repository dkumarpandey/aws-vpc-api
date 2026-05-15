# AWS VPC Provisioning Platform

Cloud-native serverless provisioning platform built using Terraform, FastAPI, AWS Lambda, API Gateway, Cognito, Step Functions, DynamoDB, and Boto3 to provision AWS VPC infrastructure asynchronously and securely.

The platform supports:
- Asynchronous VPC/subnet provisioning workflows
- JWT-secured APIs using Amazon Cognito
- Workflow orchestration using AWS Step Functions
- Provisioning state tracking using DynamoDB
- Rollback handling for partial infrastructure failures
- Modular Infrastructure-as-Code using Terraform

---

# Architecture

```text
Client
↓
Amazon Cognito Authentication (JWT)
↓
API Gateway HTTP API + JWT Authorizer
↓
AWS Lambda (FastAPI + Mangum)
↓
AWS Step Functions
↓
Provisioning Workflow Lambdas
    ├── Create VPC
    ├── Create Subnets
    ├── Persist Metadata
    └── Rollback Resources
↓
Amazon DynamoDB
↓
AWS EC2 APIs
```

---

# Features

- Asynchronous VPC provisioning workflow
- Public and private subnet provisioning
- Workflow orchestration using AWS Step Functions
- Provisioning state tracking using DynamoDB
- JWT authentication using Amazon Cognito
- API protection using API Gateway JWT Authorizer
- Rollback/compensation handling for provisioning failures
- Request status retrieval APIs
- Input validation using Pydantic
- Infrastructure as Code using Terraform
- Modular Terraform architecture
- OpenAPI / Swagger documentation

---

# Technologies Used

- Python 3.11
- FastAPI
- Mangum
- AWS Lambda
- AWS Step Functions
- Amazon API Gateway HTTP API
- Amazon Cognito
- Amazon DynamoDB
- Terraform
- Boto3
- Pydantic

---

# Project Structure

```text
aws-vpc-api/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   │
│   └── modules/
│       ├── api_gateway/
│       ├── cognito/
│       ├── dynamodb/
│       ├── iam/
│       ├── lambda/
│       └── stepfunctions/
│
├── src/
│   ├── api/
│   │   ├── main.py
│   │   ├── models.py
│   │   ├── requirements.txt
│   │   └── workflow/
│   │
│   ├── create_vpc/
│   ├── create_subnets/
│   ├── persist_metadata/
│   └── rollback/
│
└── README.md
```

---

# Provisioning Workflow

The API follows an asynchronous provisioning model.

## Provision Request Flow

1. Client invokes:
   POST /network

2. API validates request payload

3. Lambda starts Step Functions execution

4. Step Functions orchestrates:
   - VPC creation
   - Subnet creation
   - Metadata persistence

5. API immediately returns:
   - request_id
   - IN_PROGRESS status

6. Client retrieves provisioning status using:
   GET /network/status/{request_id}

7. Final infrastructure metadata is persisted in DynamoDB

---

# Prerequisites

Install the following tools before deployment:

- AWS Account
- Python 3.11
- Git
- AWS CLI
- Terraform

---

# Install Python

Download:
https://www.python.org/downloads/

Verify:

```bash
python --version
```

---

# Install AWS CLI

Download:
https://aws.amazon.com/cli/

Verify:

```bash
aws --version
```

---

# Install Terraform

Download:
https://developer.hashicorp.com/terraform/downloads

Verify:

```bash
terraform --version
```

---

# Configure AWS CLI

```bash
aws configure
```

Provide:
- AWS Access Key
- AWS Secret Key
- Region
- Output format

---

# Clone Repository

```bash
git clone https://github.com/dkumarpandey/aws-vpc-api.git
```

```bash
cd aws-vpc-api
```

---

# Install API Dependencies

```bash
cd src/api
```

```bash
pip install -r requirements.txt -t .
```

---

# Terraform Deployment

## Navigate To Terraform Directory

```bash
cd terraform
```

## Initialize Terraform

```bash
terraform init
```

## Validate Terraform

```bash
terraform validate
```

## Review Plan

```bash
terraform plan
```

## Deploy Infrastructure

```bash
terraform apply
```

---

# Terraform Outputs

Terraform deployment outputs:

- API Gateway endpoint
- Cognito User Pool ID
- Cognito App Client ID
- Lambda ARNs
- Step Functions ARN

View outputs:

```bash
terraform output
```

---

# Create Cognito User

```bash
aws cognito-idp sign-up ^
--client-id <CLIENT_ID> ^
--username demo-user@example.com ^
--password Password123! ^
--user-attributes Name=email,Value=demo-user@example.com
```

---

# Confirm User

```bash
aws cognito-idp admin-confirm-sign-up ^
--user-pool-id <USER_POOL_ID> ^
--username demo-user@example.com
```

---

# Generate JWT Token

```bash
aws cognito-idp initiate-auth ^
--auth-flow USER_PASSWORD_AUTH ^
--client-id <CLIENT_ID> ^
--auth-parameters USERNAME=demo-user@example.com,PASSWORD=Password123!
```

Copy:
- AuthenticationResult.IdToken

---

# Swagger Documentation

```text
https://<API_ID>.execute-api.<REGION>.amazonaws.com/docs
```

---

# Health Endpoint

## Endpoint

```http
GET /health
```

## Sample Response

```json
{
  "status": "UP"
}
```

---

# Create Network API

## Endpoint

```http
POST /network
```

## Headers

```http
Authorization: Bearer <ID_TOKEN>
Content-Type: application/json
```

## Sample Request

```json
{
  "vpc_cidr": "10.10.0.0/16",
  "public_subnets": [
    {
      "cidr": "10.10.1.0/24",
      "az": "ap-south-1a"
    }
  ],
  "private_subnets": [
    {
      "cidr": "10.10.11.0/24",
      "az": "ap-south-1a"
    }
  ]
}
```

---

# Sample Response

```json
{
  "request_id": "3cd2e88b-de83-4fdf-aa46-38e77a97ba08",
  "status": "IN_PROGRESS"
}
```

---

# Curl Example

```bash
curl -X POST https://<api-id>.execute-api.ap-south-1.amazonaws.com/network ^
-H "Authorization: Bearer <TOKEN>" ^
-H "Content-Type: application/json" ^
-d "{\"vpc_cidr\":\"10.80.0.0/16\",\"public_subnets\":[{\"cidr\":\"10.80.1.0/24\",\"az\":\"ap-south-1a\"}],\"private_subnets\":[{\"cidr\":\"10.80.11.0/24\",\"az\":\"ap-south-1a\"}]}"
```

---

# Get Provisioning Status

## Endpoint

```http
GET /network/status/{request_id}
```

## Headers

```http
Authorization: Bearer <ID_TOKEN>
```

## Sample Response

```json
{
  "request_id": "3cd2e88b-de83-4fdf-aa46-38e77a97ba08",
  "created_at": "2026-05-14T19:25:30.866289",
  "status": "SUCCESS",
  "vpc_id": "vpc-002e43123083e37ef",
  "subnets": [
    {
      "name": "public-10.80.1.0/24",
      "subnet_id": "subnet-07885e36395053181",
      "availability_zone": "ap-south-1a",
      "cidr": "10.80.1.0/24",
      "type": "public"
    },
    {
      "name": "private-10.80.11.0/24",
      "subnet_id": "subnet-009f32410f80b7d53",
      "availability_zone": "ap-south-1a",
      "cidr": "10.80.11.0/24",
      "type": "private"
    }
  ]
}
```

---

# Validation

The API validates:

- CIDR block format
- Required fields
- Request payload structure
- Public/private subnet configuration

Implemented using:
- Pydantic models
- Custom validators
- Python ipaddress module

---

# Security

Authentication is enforced at API Gateway layer using:

- Amazon Cognito User Pool
- JWT-based authentication
- API Gateway JWT Authorizer

Protected endpoints:
- POST /network
- GET /network/status/{request_id}

Public endpoints:
- GET /health
- /docs
- /openapi.json

---

# Rollback Handling

The workflow includes rollback/compensation handling for partial infrastructure failures.

Example scenarios:
- Subnet creation failure after VPC creation
- Metadata persistence failure
- Partial workflow execution failures

Rollback Lambda cleans up partially provisioned infrastructure resources.

---

# Cleanup Resources

```bash
terraform destroy
```

---

# Future Improvements

- Enhanced subnet overlap validation
- CloudWatch structured logging and dashboards
- CI/CD pipeline integration
- WAF integration
- Resource tagging enhancements
- Multi-region deployment support
- Rate limiting and throttling policies
- Terraform remote state management

---

# Author

Dileep Pandey

