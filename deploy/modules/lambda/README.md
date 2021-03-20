# Terraform Module: Lambda

Creates a Lambda function and configure a CloudWatch Log Group and the desired
IAM permissions.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.8 |
| aws | >= 3.33.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.33.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_triggers | Gives an external source (like a CloudWatch Event Rule, SNS, or S3) permission to access the Lambda function | `map(map(string))` | `{}` | no |
| description | Description of the lambda function | `string` | n/a | yes |
| function\_name | Name of the lambda function | `string` | n/a | yes |
| handler | The function entrypoint in the code | `string` | `"main"` | no |
| memory\_size | Amount of memory in MB of the lambda function | `number` | `128` | no |
| policies | Policies to attach to the default IAM role | `map(string)` | `{}` | no |
| prefix | Unique prefix name to identify the resources | `string` | n/a | yes |
| runtime | Runtime of the lambda function | `string` | `"go1.x"` | no |
| tags | A map of tags to add | `map(string)` | `{}` | no |
| timeout | Amount of time the lambda function has to run in seconds | `number` | `5` | no |
| variables | Environment variables that are accessible from the function code during execution | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The lambda function arn |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
