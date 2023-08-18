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
  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

resource "aws_dynamodb_table" "main" {
  name           = var.project_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 25
  write_capacity = 25
  hash_key       = "pk"
  range_key      = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }
}

resource "aws_apigatewayv2_api" "main" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

module "hello_function" {
  source = "./resource_function"

  function_name     = "hello"
  resource_name     = "hello"
  api_gateway_id    = aws_apigatewayv2_api.main.id
  lambda_role_arn   = aws_iam_role.iam_for_lambda.arn
  execution_arn     = aws_apigatewayv2_api.main.execution_arn
  api_gateway_route = "GET /hello"
}

module "rest_post_function" {
  source = "./resource_function"

  function_name     = "rest-post"
  resource_name     = "rest-post"
  api_gateway_id    = aws_apigatewayv2_api.main.id
  lambda_role_arn   = aws_iam_role.iam_for_lambda.arn
  execution_arn     = aws_apigatewayv2_api.main.execution_arn
  api_gateway_route = "POST /rest/post"
  environment = {DYNAMO_TABLE_NAME = aws_dynamodb_table.main.id}
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "example-stage"
  auto_deploy = true
}
