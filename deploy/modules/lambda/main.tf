locals {
  function_name      = var.prefix != "" ? "${var.prefix}-${var.function_name}" : var.function_name
  function_name_path = replace(var.function_name, "-", "_")
}

############################
# Lambda: function
############################

resource "aws_lambda_function" "this" {
  function_name = local.function_name
  tags          = var.tags

  # Runtime settings
  runtime = var.runtime
  handler = var.handler

  # Code package
  filename         = "../artifacts/${local.function_name_path}.zip"
  source_code_hash = filebase64sha256("../artifacts/${local.function_name_path}.zip")

  # General configuration
  description = var.description
  memory_size = var.memory_size
  timeout     = var.timeout

  # Permissions
  role = aws_iam_role.this.arn

  # Environment variables
  dynamic "environment" {
    for_each = range(length(var.variables) > 0 ? 1 : 0)
    content {
      variables = var.variables
    }
  }
}

############################
# Lambda: permissions
############################

resource "aws_iam_role" "this" {
  name               = "AWSLambda-${local.function_name}"
  description        = "IAM role for the lambda function: ${local.function_name}"
  assume_role_policy = data.aws_iam_policy_document.default_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "default_role" {
  statement {
    sid = "AssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = "AWSLambdaLogging-${local.function_name}"
  policy = data.aws_iam_policy_document.default_policy.json
}

data "aws_iam_policy_document" "default_policy" {
  statement {
    sid = "Logging"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }
}

############################
# Lambda: resource-based policies
############################

resource "aws_iam_role_policy_attachment" "extra" {
  for_each = var.policies

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.extra[each.key].arn
}

resource "aws_iam_policy" "extra" {
  for_each = var.policies

  name   = "${each.key}-${local.function_name}"
  policy = each.value
}

############################
# Lambda: resource-based policies
############################

resource "aws_lambda_permission" "this" {
  for_each = var.allowed_triggers

  function_name = aws_lambda_function.this.function_name
  qualifier     = lookup(each.value, "qualifier", null)

  statement_id = lookup(each.value, "statement_id", each.key)
  action       = lookup(each.value, "action", "lambda:InvokeFunction")
  principal    = lookup(each.value, "principal", format("%s.amazonaws.com", lookup(each.value, "service", "")))
  source_arn   = lookup(each.value, "source_arn", null)
}

############################
# Logging
############################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
  tags              = var.tags
}
