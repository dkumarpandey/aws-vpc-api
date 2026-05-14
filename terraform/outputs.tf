output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "api_lambda_arn" {
  value = module.api_lambda.lambda_function_arn
}

output "step_function_arn" {
  value = module.stepfunctions.state_machine_arn
}

output "api_endpoint" {

  value = module.api_gateway.api_endpoint
}

output "cognito_user_pool_id" {

  value = module.cognito.user_pool_id
}


output "cognito_client_id" {

  value = module.cognito.user_pool_client_id
}