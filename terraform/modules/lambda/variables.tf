variable "function_name" {
  type = string
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "source_path" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "environment_variables" {
  type = map(string)
}

variable "timeout" {
  type    = number
  default = 60
}

variable "tags" {
  type = map(string)
}