# AWS VPC Provisioning API

Serverless API built using AWS SAM, FastAPI, Lambda, API Gateway, Cognito, DynamoDB, and Boto3 to provision AWS VPC resources securely.

---

# Architecture

Client
↓
JWT Authentication(Amazon Cognito)
↓
API Gateway + Cognito Authorizer
↓
AWS Lambda (FastAPI)
↓
AWS EC2 + DynamoDB

---

# Features

- Create AWS VPCs
- Create public and private subnets
- Store provisioned resources in DynamoDB
- JWT authentication using Amazon Cognito
- API protection using API Gateway Cognito Authorizer
- OpenAPI / Swagger documentation
- Input validation using Pydantic
- Infrastructure as Code using AWS SAM

---

# Technologies Used

- Python 3.10
- FastAPI
- AWS Lambda
- AWS SAM
- Amazon API Gateway
- Amazon Cognito
- Amazon DynamoDB
- Boto3
- Pydantic

---

# Project Structure

```text
aws-vpc-api/
│
├── template.yaml
├── README.md
│
└── src/
    ├── main.py
    ├── models.py
    └── requirements.txt

# Prerequisites

Install the following tools before deployment:

- AWS Account
- Python 3.10
- Git
- AWS CLI
- AWS SAM CLI

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

# Install AWS SAM CLI

Download:
https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html

Verify:

```bash
sam --version
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

# Create Virtual Environment

```bash
python -m venv .venv
```

Activate on Windows:

```bash
.venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r src/requirements.txt
```

---

# Build Application

```bash
sam build
```

---

# Deploy Application

```bash
sam deploy --guided
```

Recommended inputs:

| Setting | Value |
|---|---|
| Stack Name | aws-vpc-api |
| AWS Region | ap-south-1 |
| Confirm changes before deploy | Yes |
| Allow SAM IAM role creation | Yes |
| Disable rollback | No |
| Save arguments to samconfig.toml | Yes |

---

# Get Stack Outputs

```bash
aws cloudformation describe-stacks \
--stack-name aws-vpc-api \
--query "Stacks[0].Outputs"
```

---

# Create Cognito User

Open:
- AWS Console
- Amazon Cognito
- User Pools
- Open generated user pool
- Create User

---

# Set Permanent Password

```bash
aws cognito-idp admin-set-user-password \
--user-pool-id <USER_POOL_ID> \
--username userName \
--password "******" \
--permanent
```

---

# Generate JWT Token

```bash
aws cognito-idp initiate-auth \
--auth-flow USER_PASSWORD_AUTH \
--client-id <APP_CLIENT_ID> \
--auth-parameters USERNAME=userName,PASSWORD=****
```

Copy:
- IdToken

---

# Swagger Documentation

```text
https://<API_ID>.execute-api.<REGION>.amazonaws.com/Prod/docs
```

---

# Create VPC API

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
      "cidr": "10.10.2.0/24",
      "az": "ap-south-1b"
    }
  ]
}
```

---

# Curl Example

```bash
curl -X POST "https://<API_URL>/network" \
-H "Authorization: Bearer <ID_TOKEN>" \
-H "Content-Type: application/json" \
-d "{\"vpc_cidr\":\"10.10.0.0/16\",\"public_subnets\":[{\"cidr\":\"10.10.1.0/24\",\"az\":\"ap-south-1a\"}],\"private_subnets\":[{\"cidr\":\"10.10.2.0/24\",\"az\":\"ap-south-1b\"}]}"
```

---

# Get VPC Details

## Endpoint

```http
GET /network/{vpc_id}
```

---

# Validation

The API validates:
- CIDR block format
- Required fields
- Request payload structure

Implemented using:
- Pydantic models
- Custom validators

---

# Security

Authentication handled using:
- Amazon Cognito User Pool
- API Gateway Cognito Authorizer
- JWT IdToken validation

Public endpoints:
- /
- /docs
- /openapi.json

Protected endpoints:
- /network
- /network/{vpc_id}

---

# Cleanup Resources

```bash
sam delete
```

---

# Future Improvements

- Least privilege IAM policies
- Adding support for tagging resources while creation
- Async provisioning workflows
- Step Functions orchestration
- Terraform support
- CloudWatch structured logging
- CI/CD pipeline
- VPC/subnet overlap validation
- API throttling and WAF

---

