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

variable "environment" {
  description = "Environment Configuration block"
  type = object({
    compute_type    = string
    image           = string
    type            = string
    privileged_mode = bool
  })
  default = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
}

# variable "vpc" {
#   type        = string
#   description = "VPC"
# }

# variable "subnets" {
#   type        = list(string)
#   description = "A map of subnet ids to assign to the DB cluster"
# }

# variable "security_group_ids" {
#   type        = list(string)
#   description = "Security group ids"
# }


