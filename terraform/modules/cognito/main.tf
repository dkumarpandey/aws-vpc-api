resource "aws_cognito_user_pool" "this" {

  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]

  password_policy {

    minimum_length = 8

    require_lowercase = true

    require_numbers = true

    require_symbols = false

    require_uppercase = true
  }

  tags = var.tags
}


resource "aws_cognito_user_pool_client" "this" {

  name = var.app_client_name

  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  generate_secret = false

  prevent_user_existence_errors = "ENABLED"

  supported_identity_providers = ["COGNITO"]
}