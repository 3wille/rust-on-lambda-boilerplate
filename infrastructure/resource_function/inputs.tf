variable "function_name" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "api_gateway_id" {
  type = string
}

variable "api_gateway_route" {
  type        = string
  description = "passed as route_key to the apigw2 route resource"
}

variable "execution_arn" {
  type = string
}

# variable "parent_resource_id" {
#   type = string
# }

variable "lambda_role_arn" {
  type = string
}

variable "environment" {
  type    = map(string)
  default = {}
}
