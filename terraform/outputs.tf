output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "api_lambda_arn" {
  value = module.api_lambda.lambda_function_arn
}