provider "aws" {
region = "us-east-1"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
}]
})
}
# Attach basic Lambda execution to write logs
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Archive the Lambda Python code
#data "archive_file" "lambda_zip" {
# type        = "zip"
#  source_dir  = "${path.module}/lambda_function"
# output_path = "${path.module}/lambda_function.zip"
# }

# Lambda Function
resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
# filename      = data.archive_file.lambda_zip.output_path
  filename      = "${path.module}/lambda_function.zip"
}
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lamda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.hello_lambda.function_name}"
  retention_in_days = 7
}

