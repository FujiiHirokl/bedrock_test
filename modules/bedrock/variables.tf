variable "region" {
  description = "AWS リージョン"
  default     = "us-east-1"
}

variable "function_name" {
  description = "Lambda関数名"
  default     = "lambda_function"
}

variable "runtime" {
  description = "Lambda関数のランタイム"
  default     = "python3.11"
}

