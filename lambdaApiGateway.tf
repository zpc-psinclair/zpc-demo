


#
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "safemarch-lambda-code-storage"
  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}



data "archive_file" "lambda_safemarch_http" {
  type = "zip"

  source_dir  = "${path.module}/lambda_api_gateway/safemarchhttp"
  output_path = "${path.module}/lambda_api_gateway/safemarchhttp.zip"
}

resource "aws_s3_bucket_object" "lambda_safemarch_http_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "safemarchhttp.zip"
  source = data.archive_file.lambda_safemarch_http.output_path

  etag = filemd5(data.archive_file.lambda_safemarch_http.output_path)
  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}



resource "aws_lambda_function" "safemarch_http" {
  function_name = "safemarchhttp"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_safemarch_http_function.key

  runtime = "nodejs12.x"
  handler = "safemarchhttp.handler"

  source_code_hash = data.archive_file.lambda_safemarch_http.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_cloudwatch_log_group" "safemarch_http_log_group" {
  name = "/aws/lambda/${aws_lambda_function.safemarch_http.function_name}"

  retention_in_days = 30

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.safemarch_http.function_name
}


resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_apigatewayv2_integration" "safemarch_http_api_integration" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.safemarch_http.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"


}

resource "aws_apigatewayv2_route" "safemarch_http_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.safemarch_http_api_integration.id}"


}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30

  tags = {
    env   = "dev"
    app   = "card-processing"
    owner = "dev-team-cardprocessing"
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.safemarch_http.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"


}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

