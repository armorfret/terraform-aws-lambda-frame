terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "apigw" {
  source  = "armorfret/apigw-lambda/aws"
  version = "0.7.3"

  source_bucket  = var.lambda_bucket
  source_version = var.lambda_version
  function_name  = "frame_${var.data_bucket}"

  environment_variables = {
    S3_BUCKET = var.config_bucket
    S3_KEY    = "config.yaml"
  }

  access_policy_document = data.aws_iam_policy_document.lambda_perms.json

  hostname = var.hostname

  binary_media_types = [
    "*/*",
  ]

  auth_source_bucket  = var.auth_lambda_bucket
  auth_source_version = var.auth_lambda_version
  auth_environment_variables = {
    S3_BUCKET = var.auth_config_bucket
    S3_KEY    = "config.yaml"
  }
  auth_access_policy_document = data.aws_iam_policy_document.auth_lambda_perms.json
  auth_ttl                    = 0
}

module "publish_user" {
  source         = "armorfret/s3-publish/aws"
  version        = "0.8.1"
  logging_bucket = var.logging_bucket
  publish_bucket = var.data_bucket
}

module "config_user" {
  source         = "armorfret/s3-publish/aws"
  version        = "0.8.1"
  logging_bucket = var.logging_bucket
  publish_bucket = var.config_bucket
  count          = var.config_bucket == var.data_bucket ? 0 : 1
}

module "auth_config_user" {
  source         = "armorfret/s3-publish/aws"
  version        = "0.8.1"
  logging_bucket = var.logging_bucket
  publish_bucket = var.auth_config_bucket
}

data "aws_iam_policy_document" "lambda_perms" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = distinct([
      "arn:aws:s3:::${var.data_bucket}/*",
      "arn:aws:s3:::${var.data_bucket}",
      "arn:aws:s3:::${var.config_bucket}/*",
      "arn:aws:s3:::${var.config_bucket}",
    ])
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/frame_${var.data_bucket}:*",
    ]
  }
}

data "aws_iam_policy_document" "auth_lambda_perms" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.auth_config_bucket}/*",
      "arn:aws:s3:::${var.auth_config_bucket}",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/frame_${var.data_bucket}_auth:*",
    ]
  }
}

resource "aws_api_gateway_gateway_response" "this" {
  rest_api_id   = module.apigw.rest_api_id
  status_code   = "401"
  response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.WWW-Authenticate" = "'Basic'"
  }
}
