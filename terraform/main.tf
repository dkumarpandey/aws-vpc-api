module "dynamodb" {

  source = "./modules/dynamodb"

  table_name = "provisioning-requests"

  hash_key = "request_id"

  attributes = [
    {
      name = "request_id"
      type = "S"
    }
  ]

  tags = var.common_tags
}


module "lambda_role" {

  source = "./modules/iam"

  role_name = "${var.project_name}-lambda-role"

  policy_name = "${var.project_name}-lambda-policy"

  tags = var.common_tags
}


module "api_lambda" {

  source = "./modules/lambda"

  function_name = "${var.project_name}-api-handler"

  runtime = var.lambda_runtime

  handler = "main.handler"

  source_path = "../src/api"

  lambda_role_arn = module.lambda_role.role_arn

  environment_variables = {
    STATE_MACHINE_ARN = module.stepfunctions.state_machine_arn
    TABLE_NAME        = module.dynamodb.table_name
  }

  tags = var.common_tags
}

module "cognito" {

  source = "./modules/cognito"

  user_pool_name = "${var.project_name}-user-pool"

  app_client_name = "${var.project_name}-app-client"

  tags = var.common_tags
}

module "api_gateway" {

  source = "./modules/api_gateway"

  api_name = "${var.project_name}-http-api"

  lambda_function_arn = module.api_lambda.lambda_function_arn

  lambda_function_name = module.api_lambda.lambda_function_name

  cognito_issuer_url = module.cognito.issuer_url

  cognito_audience = module.cognito.audience

  tags = var.common_tags
}


module "create_vpc_lambda" {

  source = "./modules/lambda"

  function_name = "${var.project_name}-create-vpc"

  runtime = var.lambda_runtime

  handler = "handler.lambda_handler"

  source_path = "../src/lambdas/create_vpc"

  lambda_role_arn = module.lambda_role.role_arn

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }

  tags = var.common_tags
}


module "create_subnets_lambda" {

  source = "./modules/lambda"

  function_name = "${var.project_name}-create-subnets"

  runtime = var.lambda_runtime

  handler = "handler.lambda_handler"

  source_path = "../src/lambdas/create_subnets"

  lambda_role_arn = module.lambda_role.role_arn

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }

  tags = var.common_tags
}


module "persist_metadata_lambda" {

  source = "./modules/lambda"

  function_name = "${var.project_name}-persist-metadata"

  runtime = var.lambda_runtime

  handler = "handler.lambda_handler"

  source_path = "../src/lambdas/persist_metadata"

  lambda_role_arn = module.lambda_role.role_arn

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }

  tags = var.common_tags
}


module "rollback_lambda" {

  source = "./modules/lambda"

  function_name = "${var.project_name}-rollback-resources"

  runtime = var.lambda_runtime

  handler = "handler.lambda_handler"

  source_path = "../src/lambdas/rollback_resources"

  lambda_role_arn = module.lambda_role.role_arn

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }

  tags = var.common_tags
}

module "stepfunctions" {
  source = "./modules/stepfunctions"

  state_machine_name = "${var.project_name}-workflow"

  role_name = "${var.project_name}-stepfunctions-role"

  create_vpc_lambda_arn = module.create_vpc_lambda.lambda_function_arn

  create_subnets_lambda_arn = module.create_subnets_lambda.lambda_function_arn

  persist_metadata_lambda_arn = module.persist_metadata_lambda.lambda_function_arn

  rollback_lambda_arn = module.rollback_lambda.lambda_function_arn

  tags = var.common_tags
}