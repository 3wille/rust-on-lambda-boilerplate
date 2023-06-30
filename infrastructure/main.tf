terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "rust-lambda-boilerplate"
}

# resource "aws_api_gateway_rest_api" "main" {
#   name = var.project_name
# }

resource "aws_apigatewayv2_api" "main" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

module "example" {
  source = "./resource_function"

  function_name      = "example_api"
  resource_name      = "example"
  api_gateway_id = aws_apigatewayv2_api.main.id
  # parent_resource_id = aws_api_gateway_rest_api.main.root_resource_id
  lambda_role_arn           = aws_iam_role.iam_for_lambda.arn
  execution_arn = aws_apigatewayv2_api.main.execution_arn
}

# resource "aws_api_gateway_deployment" "main" {
#   rest_api_id = aws_api_gateway_rest_api.main.id

#   triggers = {
#     # NOTE: The configuration below will satisfy ordering considerations,
#     #       but not pick up all future REST API changes. More advanced patterns
#     #       are possible, such as using the filesha1() function against the
#     #       Terraform configuration file(s) or removing the .id references to
#     #       calculate a hash against whole resources. Be aware that using whole
#     #       resources will show a difference after the initial implementation.
#     #       It will stabilize to only change when resources change afterwards.
#     redeployment = sha1(jsonencode([
#       module.example.api_resource_id
#       # aws_api_gateway_resource.example.id,
#       # aws_api_gateway_method.example.id,
#       # aws_api_gateway_integration.example.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "example" {
#   deployment_id = aws_api_gateway_deployment.main.id
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   stage_name    = "example"
# }

resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "example-stage"
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  description = "Example deployment"

  lifecycle {
    create_before_destroy = true
  }
}
