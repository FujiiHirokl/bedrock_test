# Bedrock Lambda Function Module

**概要**: このTerraformモジュールは、Amazon Bedrockを使用するLambda関数を作成するためのものです。Bedrockを利用して高性能なAIモデルを活用できるLambda関数を簡単にセットアップできます。

## 前提条件

- Terraformがインストールされていること。
- AWSアカウントへのアクセス権を持っていること。
- 指定したリージョンでbedrockへのアクセスが許可されていること

## リージョンの設定
```hcl
provider "aws" {
  region = var.region  # 使用するリージョンを指定
}
```
## Lambda関数の作成
次に、Lambda関数を作成します。この関数はBedrockを使用してAIモデルを実行します。

```hcl
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
```

## Lambda関数のIAMロールとIAMポリシー
Lambda関数用のIAMロールとIAMポリシーを作成します。
```hcl
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```
## CloudWatchロググループの作成
Lambda関数のログをCloudWatchに送信するためのロググループを作成します。

```hcl
Copy code
resource "aws_cloudwatch_log_group" "example_log_group" {
  name = "/aws/lambda/${aws_lambda_function.example_lambda.function_name}"
  retention_in_days = 30
}
```
## カスタムLambdaレイヤー
Bedrockを使用するために必要なカスタムLambdaレイヤーを定義します。

```hcl
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "../../modules/bedrock/boto3_1.28.69.zip"
  layer_name = "boto3_layer"
  compatible_runtimes = ["python3.11"]
}
```
