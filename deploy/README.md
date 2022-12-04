# Infrastructure as code

Terraform code to deploy the infrastructure.

## Architecture

![Diagram](../docs/img/cann-architecture.png)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.44.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.44.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_check_announcement_lambda"></a> [check\_announcement\_lambda](#module\_check\_announcement\_lambda) | ./modules/lambda | n/a |
| <a name="module_send_notification_lambda"></a> [send\_notification\_lambda](#module\_send\_notification\_lambda) | ./modules/lambda | n/a |
| <a name="module_send_telegram_notification_lambda"></a> [send\_telegram\_notification\_lambda](#module\_send\_telegram\_notification\_lambda) | ./modules/lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.check_announcement_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.check_announcement_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_dynamodb_table.default](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/dynamodb_table) | resource |
| [aws_lambda_event_source_mapping.dynamodb_send_notification_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_sns_topic.default](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.default](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/sns_topic_subscription) | resource |
| [aws_ssm_parameter.telegram_auth_token](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/resources/ssm_parameter) | resource |
| [aws_iam_policy_document.dynamodb_check_announcement_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dynamodb_send_notification_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_send_notification_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_send_telegram_notification_lambda](https://registry.terraform.io/providers/hashicorp/aws/3.44.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_announcements"></a> [announcements](#input\_announcements) | Target announcements checks | <pre>map(object({<br>    base_url           = string<br>    date_format        = string<br>    telegram_chat_id   = string<br>    telegram_chat_name = string<br>  }))</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix name to identify the resources | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-1"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Scheduling expression to check a new announcement | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add | `map(string)` | <pre>{<br>  "App": "cann",<br>  "CreatedBy": "terraform",<br>  "Environment": "production"<br>}</pre> | no |
| <a name="input_telegram_auth_token"></a> [telegram\_auth\_token](#input\_telegram\_auth\_token) | Telegram Auth Token to publish new announcements | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
