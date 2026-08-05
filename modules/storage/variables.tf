variable "bucket_name" {
  type        = string
  nullable    = false
  description = "The globally unique S3 bucket name."
  validation {
    # https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "The \"bucket_name\" value must be 3 to 63 lowercase alphanumeric characters, hyphens, and dots."
  }
}
