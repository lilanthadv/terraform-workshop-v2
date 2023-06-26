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
  description = "The name of your security resource"
  type        = string
}

variable "description" {
  type        = string
  description = "The description"
}

variable "ecr_repository_image_tag_mutability" {
  type        = string
  description = "ECR Repository Image Tag Mutability"
  default     = "MUTABLE"
}
