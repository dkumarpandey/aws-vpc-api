variable "state_machine_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "create_vpc_lambda_arn" {
  type = string
}

variable "create_subnets_lambda_arn" {
  type = string
}

variable "persist_metadata_lambda_arn" {
  type = string
}

variable "rollback_lambda_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}