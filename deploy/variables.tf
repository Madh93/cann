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
    telegram_chat_id      = string
    telegram_channel_name = string
  }))
}

variable "base_url" {
  description = "The base url where announcements are published"
  type        = string
  default     = "http://www.gobcan.es/educacion/Nombramientos/Documentos"
}

variable "date_format" {
  description = "Date format used in announcements filenames"
  type        = string
  default     = "02-01-06"
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
