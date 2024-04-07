variable "lambda_version" {
  description = "Version of the Lambda to use"
  type        = string
  default     = "v0.2.1"
}

variable "logging_bucket" {
  description = "S3 bucket to use for bucket logging"
  type        = string
}

variable "config_bucket" {
  description = "S3 bucket to use for configuration"
  type        = string
}

variable "auth_config_bucket" {
  description = "S3 bucket to use for auth configuration"
  type        = string
}

variable "data_bucket" {
  description = "S3 bucket from which to read data"
  type        = string
}

variable "lambda_bucket" {
  description = "S3 bucket from which to read the Lambda ZIP"
  type        = string
}

variable "auth_lambda_bucket" {
  description = "S3 bucket from which to read the auth Lambda ZIP"
  type        = string
}

variable "auth_lambda_version" {
  description = "Version of the Lambda to use"
  type        = string
  default     = "v0.1.0"
}

variable "hostname" {
  description = "Hostname to use for the site"
  type        = string
}

variable "cloudwatch_retention_in_days" {
  description = "Days to retain cloudwatch logs"
  type        = number
  default     = 30
}
