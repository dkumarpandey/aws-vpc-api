variable "api_name" {

  type = string
}


variable "lambda_function_arn" {

  type = string
}


variable "lambda_function_name" {

  type = string
}

variable "cognito_issuer_url" {

  type = string
}


variable "cognito_audience" {

  type = string
}

variable "tags" {

  type = map(string)

  default = {}
}

