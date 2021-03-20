variable "prefix" {
  description = "Unique prefix name to identify the resources"
  type        = string
}

variable "function_name" {
  description = "Name of the lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime of the lambda function"
  type        = string
  default     = "go1.x"
}

variable "handler" {
  description = "The function entrypoint in the code"
  type        = string
  default     = "main"
}

variable "description" {
  description = "Description of the lambda function"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB of the lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Amount of time the lambda function has to run in seconds"
  type        = number
  default     = 5
}

variable "variables" {
  description = "Environment variables that are accessible from the function code during execution"
  type        = map(any)
  default     = {}
}

variable "policies" {
  description = "Policies to attach to the default IAM role"
  type        = map(string)
  default     = {}
}

variable "allowed_triggers" {
  description = "Gives an external source (like a CloudWatch Event Rule, SNS, or S3) permission to access the Lambda function"
  type        = map(map(string))
  default     = {}
}

variable "tags" {
  description = "A map of tags to add"
  type        = map(string)
  default     = {}
}
