variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "bucket_description" {
  type        = string
  description = "The description of the bucket"
}

variable "custom_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = null
}

variable "enable_force_destroy" {
  description = "Enable Force Destroy"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable Versioning for S3 Bucket"
  type        = bool
  default     = false
}

variable "acl" {
  description = "Access Control List (ACL) for the S3 bucket"
  type        = string
  default     = "private"

  validation {
    condition     = can(regex("^(private|public-read|public-read-write|authenticated-read|aws-exec-read|bucket-owner-read|bucket-owner-full-control)$", var.acl))
    error_message = "Invalid ACL. Please choose one of the following: private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control."
  }
}

variable "public_access_block" {
  description = "Configuration for S3 bucket public access block"

  type = object({
    block_public_acls       = optional(bool, false)
    block_public_policy     = optional(bool, false)
    ignore_public_acls      = optional(bool, false)
    restrict_public_buckets = optional(bool, false)
  })

  default = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }
}
