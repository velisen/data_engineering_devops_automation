variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my-project"

}

variable "use_existing_bucket" {
  description = "Flag to indicate if an existing S3 bucket should be used"
  type        = bool
  default     = false

}

variable "existing_bucket_name" {
  description = "The name of the existing S3 bucket to use"
  type        = string
  default     = ""
  validation {
    condition     = var.use_existing_bucket ? length(var.existing_bucket_name) > 0 : true
    error_message = "If 'use_existing_bucket' is true, 'existing_bucket_name' must not be empty."
  }

}
