provider "aws" {
  region = var.region
}

locals {
  prefix = var.prefix != "" ? "${var.prefix}-" : ""
}

############################
# DynamoDB
############################

resource "aws_dynamodb_table" "default" {
  for_each = var.announcements

  name     = "${local.prefix}${each.key}-announcements-table"
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
  for_each = var.announcements

  name = "${local.prefix}${each.key}-announcements-topic"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "default" {
  for_each = var.announcements

  topic_arn = aws_sns_topic.default[each.key].arn
  protocol  = "lambda"
  endpoint  = module.send_telegram_notification_lambda[each.key].arn
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

  rule = aws_cloudwatch_event_rule.check_announcement_lambda[each.key].name
  arn  = module.check_announcement_lambda[each.key].arn
}

############################
# Lambda: check_announcement
############################

module "check_announcement_lambda" {
  source = "./modules/lambda"

  for_each = var.announcements

  prefix        = "${local.prefix}${each.key}"
  function_name = "check-announcement"
  description   = "Check if a new announcement has been published"
  tags          = var.tags

  variables = {
    BASE_URL       = each.value.base_url
    DATE_FORMAT    = each.value.date_format
    DYNAMODB_TABLE = aws_dynamodb_table.default[each.key].id
    PREFIX         = upper(each.key)
  }

  policies = {
    AWSLambdaDynamoDB = data.aws_iam_policy_document.dynamodb_check_announcement_lambda[each.key].json
  }

  allowed_triggers = {
    CloudWatchEvents = {
      service    = "events"
      source_arn = aws_cloudwatch_event_rule.check_announcement_lambda[each.key].arn
    }
  }
}

data "aws_iam_policy_document" "dynamodb_check_announcement_lambda" {
  for_each = var.announcements

  statement {
    sid = "DynamoDBItemOperations"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.default[each.key].arn
    ]
  }
}

############################
# Lambda: send_notification
############################

module "send_notification_lambda" {
  source = "./modules/lambda"

  for_each = var.announcements

  prefix        = "${local.prefix}${each.key}"
  function_name = "send-notification"
  description   = "Notifies to SNS that a new announcement has been published"
  tags          = var.tags

  variables = {
    TOPIC_ARN = aws_sns_topic.default[each.key].arn
  }

  policies = {
    AWSLambdaDynamoDB = data.aws_iam_policy_document.dynamodb_send_notification_lambda[each.key].json
    AWSLambdaSNS      = data.aws_iam_policy_document.sns_send_notification_lambda[each.key].json
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_send_notification_lambda" {
  for_each = var.announcements

  event_source_arn  = aws_dynamodb_table.default[each.key].stream_arn
  function_name     = module.send_notification_lambda[each.key].arn
  starting_position = "LATEST"
  batch_size        = 1
}

data "aws_iam_policy_document" "dynamodb_send_notification_lambda" {
  for_each = var.announcements

  statement {
    sid = "AllowDynamoDBStreams"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [
      aws_dynamodb_table.default[each.key].stream_arn
    ]
  }
}

data "aws_iam_policy_document" "sns_send_notification_lambda" {
  for_each = var.announcements

  statement {
    sid = "AllowSNSPublish"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.default[each.key].arn
    ]
  }
}

############################
# Lambda: send_telegram_notification
############################

module "send_telegram_notification_lambda" {
  source = "./modules/lambda"

  for_each = var.announcements

  prefix        = "${local.prefix}${each.key}"
  function_name = "send-telegram-notification"
  description   = "Send a Telegram notification when a new announcement has been published"
  timeout       = 10
  tags          = var.tags

  variables = {
    TELEGRAM_CHAT_ID          = each.value.telegram_chat_id   # Deprecated in favor of 'SSM_TELEGRAM_CHAT_ID'
    TELEGRAM_CHAT_NAME        = each.value.telegram_chat_name # Deprecated in favor of 'SSM_TELEGRAM_CHANNEL_NAME'
    SSM_TELEGRAM_AUTH_TOKEN   = "/announcements/telegram/token"
    SSM_TELEGRAM_CHAT_ID      = "/announcements/telegram/{{.AnnouncementID}}/chat_id"
    SSM_TELEGRAM_CHANNEL_NAME = "/announcements/telegram/{{.AnnouncementID}}/channel_name"
  }

  policies = {
    AWSLambdaSSM = data.aws_iam_policy_document.ssm_send_telegram_notification_lambda[each.key].json
  }

  allowed_triggers = {
    SNS = {
      service    = "sns"
      source_arn = aws_sns_topic.default[each.key].arn
    }
  }
}

data "aws_iam_policy_document" "ssm_send_telegram_notification_lambda" {
  for_each = var.announcements

  statement {
    sid = "AllowGetParameterFromSSM"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.telegram_auth_token.arn
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
