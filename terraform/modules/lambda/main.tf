data "archive_file" "lambda_zip" {

  type = "zip"

  source_dir  = var.source_path
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {

  function_name = var.function_name

  runtime = var.runtime

  role = var.lambda_role_arn

  handler = var.handler

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = var.timeout

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}