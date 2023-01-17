provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  prefix     = var.prefix != "" ? "${var.prefix}-" : ""
  account_id = data.aws_caller_identity.current.account_id
}

############################
# DynamoDB
############################

resource "aws_dynamodb_table" "default" {
  name     = "${local.prefix}announcements-table"
  hash_key = "URL"
  tags     = var.tags

  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "URL"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "TTL"
  }
}

############################
# SNS
############################

resource "aws_sns_topic" "default" {
  name = "${local.prefix}announcements-topic"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "default" {
  topic_arn = aws_sns_topic.default.arn
  protocol  = "lambda"
  endpoint  = module.send_telegram_notification_lambda.arn
}

############################
# CloudWatch Events
############################

resource "aws_cloudwatch_event_rule" "check_announcement_lambda" {
  for_each = var.announcements

  name                = "${local.prefix}${each.key}-check-announcement"
  description         = "Check if a new announcement has been published"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "check_announcement_lambda" {
  for_each = var.announcements

  rule  = aws_cloudwatch_event_rule.check_announcement_lambda[each.key].name
  arn   = module.check_announcement_lambda.arn
  input = jsonencode({ AnnouncementID = upper(each.key) })
}

############################
# Lambda: check_announcement
############################

module "check_announcement_lambda" {
  source = "./modules/lambda"

  prefix        = var.prefix
  function_name = "check-announcement"
  description   = "Check if a new announcement has been published"
  tags          = var.tags

  variables = {
    BASE_URL       = var.base_url
    DATE_FORMAT    = var.date_format
    DYNAMODB_TABLE = aws_dynamodb_table.default.id
  }

  policies = {
    AWSLambdaDynamoDB = data.aws_iam_policy_document.dynamodb_check_announcement_lambda.json
  }

  allowed_triggers = { for announcementID, _ in var.announcements :
    "${announcementID}CloudWatchEvents" => {
      service    = "events"
      source_arn = aws_cloudwatch_event_rule.check_announcement_lambda[announcementID].arn
    }
  }
}

data "aws_iam_policy_document" "dynamodb_check_announcement_lambda" {
  statement {
    sid = "DynamoDBItemOperations"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.default.arn
    ]
  }
}

############################
# Lambda: send_notification
############################

module "send_notification_lambda" {
  source = "./modules/lambda"

  prefix        = var.prefix
  function_name = "send-notification"
  description   = "Notifies to SNS that a new announcement has been published"
  tags          = var.tags

  variables = {
    TOPIC_ARN = aws_sns_topic.default.arn
  }

  policies = {
    AWSLambdaDynamoDB = data.aws_iam_policy_document.dynamodb_send_notification_lambda.json
    AWSLambdaSNS      = data.aws_iam_policy_document.sns_send_notification_lambda.json
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_send_notification_lambda" {
  event_source_arn  = aws_dynamodb_table.default.stream_arn
  function_name     = module.send_notification_lambda.arn
  starting_position = "LATEST"
  batch_size        = 1
}

data "aws_iam_policy_document" "dynamodb_send_notification_lambda" {
  statement {
    sid = "AllowDynamoDBStreams"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [
      aws_dynamodb_table.default.stream_arn
    ]
  }
}

data "aws_iam_policy_document" "sns_send_notification_lambda" {
  statement {
    sid = "AllowSNSPublish"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.default.arn
    ]
  }
}

############################
# Lambda: send_telegram_notification
############################

module "send_telegram_notification_lambda" {
  source = "./modules/lambda"

  prefix        = var.prefix
  function_name = "send-telegram-notification"
  description   = "Send a Telegram notification when a new announcement has been published"
  timeout       = 10
  tags          = var.tags

  variables = {
    SSM_TELEGRAM_AUTH_TOKEN   = "/announcements/telegram/token"
    SSM_TELEGRAM_CHAT_ID      = "/announcements/telegram/{{.AnnouncementID}}/chat_id"
    SSM_TELEGRAM_CHANNEL_NAME = "/announcements/telegram/{{.AnnouncementID}}/channel_name"
  }

  policies = {
    AWSLambdaSSM = data.aws_iam_policy_document.ssm_send_telegram_notification_lambda.json
  }

  allowed_triggers = {
    SNS = {
      service    = "sns"
      source_arn = aws_sns_topic.default.arn
    }
  }
}

data "aws_iam_policy_document" "ssm_send_telegram_notification_lambda" {
  statement {
    sid = "AllowGetParameterFromSSM"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/announcements/telegram/*"
    ]
  }
}

############################
# SSM: Telegram
############################

resource "aws_ssm_parameter" "telegram_auth_token" {
  name        = "/announcements/telegram/token"
  description = "Telegram Auth Token to publish new announcements"
  value       = var.telegram_auth_token
  type        = "SecureString"
  overwrite   = true
  tags        = var.tags
}

resource "aws_ssm_parameter" "telegram_chat_id" {
  for_each = var.announcements

  name        = "/announcements/telegram/${each.key}/chat_id"
  description = "Telegram Chat ID where to publish new announcements"
  value       = each.value.telegram_chat_id
  type        = "String"
  overwrite   = true
  tags        = var.tags
}

resource "aws_ssm_parameter" "telegram_channel_name" {
  for_each = var.announcements

  name        = "/announcements/telegram/${each.key}/channel_name"
  description = "Telegram Channel Name where to publish new announcements"
  value       = each.value.telegram_channel_name
  type        = "String"
  overwrite   = true
  tags        = var.tags
}
