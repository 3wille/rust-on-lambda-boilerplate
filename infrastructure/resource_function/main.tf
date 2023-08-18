locals {
  filename = "../target/lambda/${var.function_name}/bootstrap.zip"
}

resource "aws_lambda_function" "example" {
  filename         = local.filename
  source_code_hash = filebase64sha256(local.filename)
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = "rust.handler"
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  environment {
    variables = var.environment
  }
}

resource "aws_apigatewayv2_integration" "example" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda ${var.function_name}"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.example.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = var.api_gateway_id
  route_key = var.api_gateway_route

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${var.execution_arn}/*"
}
