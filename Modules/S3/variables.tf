variable "service" {
  description = "Service details"
  type = object({
    app_name             = string
    app_environment      = string
    app_version          = string
    user                 = string
    resource_name_prefix = string
  })
}

variable "name" {
  description = "The name for the resource"
  type        = string
}

variable "description" {
  type        = string
  description = "The description"
}

variable "force_destroy" {
  type        = bool
  description = "Force Destroy"
  default     = false
}

variable "acl" {
  type        = string
  description = "ACL"
  default     = "private"
}

variable "enable_versioning" {
  type        = bool
  description = "The enable versioning"
  default     = false
}

variable "enable_cloudfront" {
  type        = bool
  description = "The enable cloudfront"
  default     = false
}
