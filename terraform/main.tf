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
    TABLE_NAME = module.dynamodb.table_name
  }

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