# Terraform Module: Lambda

Creates a Lambda function and configure a CloudWatch Log Group and the desired
IAM permissions.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.44.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.44.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.default_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_triggers"></a> [allowed\_triggers](#input\_allowed\_triggers) | Gives an external source (like a CloudWatch Event Rule, SNS, or S3) permission to access the Lambda function | `map(map(string))` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the lambda function | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the lambda function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | The function entrypoint in the code | `string` | `"main"` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB of the lambda function | `number` | `128` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Policies to attach to the default IAM role | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix name to identify the resources | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime of the lambda function | `string` | `"go1.x"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Amount of time the lambda function has to run in seconds | `number` | `5` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Environment variables that are accessible from the function code during execution | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The lambda function arn |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
