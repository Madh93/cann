# Infrastructure as code

Terraform code to deploy the infrastructure.

## Architecture

![Diagram](../docs/img/cann-architecture.png)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | 0.14.8 |
| aws | 3.33.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 3.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| check_announcement_lambda | ./modules/lambda |  |
| send_notification_lambda | ./modules/lambda |  |
| send_telegram_notification_lambda | ./modules/lambda |  |

## Resources

| Name |
|------|
| [aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/cloudwatch_event_rule) |
| [aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/cloudwatch_event_target) |
| [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/dynamodb_table) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/data-sources/iam_policy_document) |
| [aws_lambda_event_source_mapping](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/lambda_event_source_mapping) |
| [aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/sns_topic) |
| [aws_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/sns_topic_subscription) |
| [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/3.33.0/docs/resources/ssm_parameter) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| announcements | Target announcements checks | <pre>map(object({<br>    base_url         = string<br>    date_format      = string<br>    telegram_chat_id = string<br>  }))</pre> | n/a | yes |
| prefix | Unique prefix name to identify the resources | `string` | `""` | no |
| region | AWS region | `string` | `"eu-west-1"` | no |
| schedule\_expression | Scheduling expression to check a new announcement | `string` | n/a | yes |
| tags | A map of tags to add | `map(string)` | <pre>{<br>  "App": "cann",<br>  "CreatedBy": "terraform",<br>  "Environment": "production"<br>}</pre> | no |
| telegram\_auth\_token | Telegram Auth Token to publish new announcements | `string` | n/a | yes |

## Outputs

No output.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
