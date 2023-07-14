variable "codebuild_app_name" {
  description = "Codebuild App Name"
  type        = string
}
variable "codebuild_app_description" {
  type        = string
  description = "Codebuild App Description"
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null
}

variable "codedeploy_role" {
  type        = string
  description = "The Code Deploy role"
}

variable "git_source" {
  description = "Git Source configuration"
  type = object({
    git_source_type    = string
    git_repository_url = string
  })
}

variable "build_timeout" {
  type        = number
  description = "Build Timeout, Number of minutes, from 5 to 480 (8 hours)"
  default     = 60
}


variable "artifacts" {
  description = "Artifacts Configuration block"
  type = object({
    type = string
  })
  default = {
    type = "NO_ARTIFACTS"
  }
}

variable "cloudwatch_logs_group_name" {
  type        = string
  description = "Cloudwatch Logs Group Name"
  default     = "log-group"
}

variable "cloudwatch_logs_stream_name" {
  type        = string
  description = "Cloudwatch Logs Stream Name"
  default     = "log-stream"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "environment_compute_type" {
  type        = string
  description = "Environment Compute Type"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_image" {
  type        = string
  description = "Environment Image"
  default     = "aws/codebuild/standard:5.0"
}

variable "environment_type" {
  type        = string
  description = "Environment Type"
  default     = "LINUX_CONTAINER"
}

variable "environment_privileged_mode" {
  type        = bool
  description = "Environment Privileged Mode"
  default     = true
}

variable "enable_vpc" {
  type        = bool
  description = "Code Build Enable VPC"
  default     = false
}

variable "vpc" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}
