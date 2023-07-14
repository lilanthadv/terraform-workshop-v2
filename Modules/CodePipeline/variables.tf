variable "codepipeline_name" {
  description = "Codepipeline Name"
  type        = string
}

variable "codepipeline_description" {
  type        = string
  description = "Codepipeline description"
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null
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

