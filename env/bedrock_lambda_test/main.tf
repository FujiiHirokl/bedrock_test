module "bedrock" {
    source = "../../modules/bedrock"

    region = "us-west-1"
    function_name = "bedrock_function"
    runtime =  "python3.11"
}

module "apigateway" {
  source = "../../modules/apigateway"
  aws_lambda_arn = module.bedrock.lambda_function_invoke_arn
  lambda_function_name = module.bedrock.function_name
  
}