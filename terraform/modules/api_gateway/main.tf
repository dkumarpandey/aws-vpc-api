resource "aws_apigatewayv2_api" "this" {

  name = var.api_name

  protocol_type = "HTTP"

  tags = var.tags
}


resource "aws_apigatewayv2_integration" "lambda_integration" {

  api_id = aws_apigatewayv2_api.this.id

  integration_type = "AWS_PROXY"

  integration_uri = var.lambda_function_arn

  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {

  api_id = aws_apigatewayv2_api.this.id

  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  name = "cognito-jwt-authorizer"

  jwt_configuration {

    audience = [var.cognito_audience]

    issuer = var.cognito_issuer_url
  }
}

resource "aws_apigatewayv2_route" "health_route" {

  api_id = aws_apigatewayv2_api.this.id

  route_key = "GET /health"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "network_route" {

  api_id = aws_apigatewayv2_api.this.id

  route_key = "POST /network"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"

  authorization_type = "JWT"

  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "status_route" {

  api_id = aws_apigatewayv2_api.this.id

  route_key = "GET /network/status/{request_id}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"

  authorization_type = "JWT"

  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}


resource "aws_apigatewayv2_stage" "default" {

  api_id = aws_apigatewayv2_api.this.id

  name = "$default"

  auto_deploy = true

  tags = var.tags
}


resource "aws_lambda_permission" "allow_apigateway" {

  statement_id = "AllowExecutionFromAPIGateway"

  action = "lambda:InvokeFunction"

  function_name = var.lambda_function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*"
}