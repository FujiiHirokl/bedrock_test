
provider "aws" {
  region = "us-east-1"  # 使用するリージョンを指定
}

# Lambda関数用のソースコードをアーカイブ
data "archive_file" "example_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/example_lambda.zip"
}


# Lambda関数の定義
resource "aws_lambda_function" "example_lambda" {
  function_name    = var.function_name
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  filename         = data.archive_file.example_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.example_zip.output_path)
  role             = aws_iam_role.lambda_role.arn
  layers           = [aws_lambda_layer_version.lambda_layer.arn]  # カスタムレイヤーを設定
}

# Lambda関数用のIAMロールの定義
resource "aws_iam_role" "lambda_role" {
  name = "example-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Lambda関数用のIAMポリシーの定義
resource "aws_iam_policy" "lambda_policy" {
  name        = "example-lambda-policy"
  description = "Lambda関数のためのIAMポリシー"
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "bedrock:*"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          aws_cloudwatch_log_group.example_log_group.arn,
          "${aws_cloudwatch_log_group.example_log_group.arn}:*"
        ]
      }
    ]
  })
}

# Lambda関数用のIAMロールとIAMポリシーの関連付け
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda関数用のCloudWatchロググループの定義
resource "aws_cloudwatch_log_group" "example_log_group" {
  name = "/aws/lambda/${aws_lambda_function.example_lambda.function_name}"
  retention_in_days = 30
}

# カスタムLambdaレイヤーの定義
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "../../modules/bedrock/boto3_1.28.69.zip"
  layer_name = "boto3_layer"
  compatible_runtimes = ["python3.11"]
}