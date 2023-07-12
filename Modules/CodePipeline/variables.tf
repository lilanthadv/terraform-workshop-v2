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

variable "pipe_role" {
  type        = string
  description = "The Pipe Role"
}

variable "codebuild_project" {
  type        = string
  description = "Codebuild Project Id"
}

variable "git_repository_name" {
  type        = string
  description = "Git Repository Name"
}

variable "git_branch_name" {
  type        = string
  description = "Git Repository Branch Name"
}

variable "artifact_store_type" {
  description = "Code Pipeline Artifact Store Type"
  default     = "S3"
}

variable "artifact_store_s3_bucket" {
  type        = string
  description = "Code Pipeline Artifact Store S3 Bucket"
}

