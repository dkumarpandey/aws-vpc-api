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