module "bedrock" {
    source = "../../modules/bedrock"
    
    # Bedrockモジュールの入力変数を設定
    region = "us-east-1"          # AWS リージョン
    function_name = "bedrock_function"  # Lambda関数名
    runtime =  "python3.11"        # Pythonランタイムバージョン
}

module "apigateway" {
    source = "../../modules/apigateway"

    # API Gatewayモジュールの入力変数を設定
    aws_lambda_arn = module.bedrock.lambda_function_invoke_arn  # Bedrock Lambda関数のARN
    lambda_function_name = module.bedrock.function_name          # Bedrock Lambda関数名
}