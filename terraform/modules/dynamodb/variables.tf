variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "attributes" {

  type = list(object({
    name = string
    type = string
  }))
}

variable "tags" {
  type = map(string)
}