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

resource "aws_apigatewayv2_api" "main" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

module "example" {
  source = "./resource_function"

  function_name  = "example_api"
  resource_name  = "example"
  api_gateway_id = aws_apigatewayv2_api.main.id
  # parent_resource_id = aws_api_gateway_rest_api.main.root_resource_id
  lambda_role_arn = aws_iam_role.iam_for_lambda.arn
  execution_arn   = aws_apigatewayv2_api.main.execution_arn
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "example-stage"
  auto_deploy = true
}
