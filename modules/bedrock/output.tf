# Lambda関数のARNを出力
output "lambda_function_arn" {
  value = aws_lambda_function.example_lambda.arn
}

# Lambda関数のInvoke ARNを出力
output "lambda_function_invoke_arn" {
  value = aws_lambda_function.example_lambda.invoke_arn
}

# Lambda関数の名前を出力
output "function_name" {
  value = var.function_name
}