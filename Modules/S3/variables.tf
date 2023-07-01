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

variable "cloudfront_alternate_domain_names" {
  type        = list(string)
  description = "Cloudfront Alternate Domain Names"
  default     = []
}

variable "cloudfront_certificate_arn" {
  type        = string
  description = "Cloudfront Certificate ARN"
  default     = ""
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "Cloudfront Minimum Protocol Version"
  default     = "TLSv1.2_2021"
}

variable "cloudfront_ssl_support_method" {
  type        = string
  description = "Cloudfront SSL Support Method"
  default     = "sni-only"
}
