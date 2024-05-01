variable "bucket_name" {
  type = string
}

variable "force_destroy" {
  type = bool
  default = true
}

variable "attach_policy" {
  type = bool
  default = false
}

variable "bucket_policy" {
  type = string
  default = null
}

variable "versioning" {
  type = bool
  default = false
}
