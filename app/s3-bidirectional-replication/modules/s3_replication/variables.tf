variable "app_name" {
  type = string
}

variable "source_s3_bucket" {
  type = string
}

variable "source_kms_key_id" {
  type    = string
  default = null
}

variable "replication_s3_bucket" {
  type = string
}

variable "replica_kms_key_id" {
  type    = string
  default = null
}

