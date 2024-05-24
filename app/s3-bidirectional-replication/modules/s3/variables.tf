variable "app_name" {
  type = string
}

variable "encryption_type" {
  description = "The type of encryption: AES256, aws:kms, or aws:kms:dsse"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for SSE-KMS or DSSE-KMS"
  type        = string
  default     = null
}
