# Lambda 関数の ARN
output "lambda_function_arn" {
  value = aws_lambda_function.example_lambda.arn
}

# Lambda 関数の ARN
output "lambda_function_invoke_arn" {
  value = aws_lambda_function.example_lambda.invoke_arn
}

output "function_name" {
  value = var.function_name
}