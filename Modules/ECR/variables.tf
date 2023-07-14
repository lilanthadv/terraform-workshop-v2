variable "ecr_name" {
  description = "ECR Repository Name"
  type        = string
}

variable "ecr_description" {
  type        = string
  description = "ECR Repository Description"
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null
}

variable "ecr_repository_image_tag_mutability" {
  type        = string
  description = "ECR Repository Image Tag Mutability"
  default     = "MUTABLE"
}
