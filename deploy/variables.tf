variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Unique prefix name to identify the resources"
  type        = string
  default     = ""
}

variable "announcements" {
  description = "Target announcements checks"
  type = map(object({
    base_url           = string
    date_format        = string
    telegram_chat_id   = string
    telegram_chat_name = string
  }))
}

variable "schedule_expression" {
  description = "Scheduling expression to check a new announcement"
  type        = string
}

variable "telegram_auth_token" {
  description = "Telegram Auth Token to publish new announcements"
  type        = string
  sensitive   = true
}


variable "tags" {
  description = "A map of tags to add"
  type        = map(string)
  default = {
    App         = "cann"
    CreatedBy   = "terraform"
    Environment = "production"
  }
}
