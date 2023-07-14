variable "role_name" {
  description = "The name for the Role"
  type        = string
}

variable "role_description" {
  type        = string
  description = "The description"
}


variable "ecs_task_role_name" {
  description = "The name for the Ecs Task Role"
  type        = string
  default     = null
}

variable "ecs_task_role_description" {
  description = "The name for the Ecs Task Role description"
  type        = string
  default     = null
}

variable "custom_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = null
}

variable "create_ecs_role" {
  description = "Set this variable to true if you want to create a role for ECS"
  type        = bool
  default     = false
}


variable "create_codebuild_role" {
  description = "Set this variable to true if you want to create a role for Codebuild"
  type        = bool
  default     = false
}

variable "create_codedeploy_role" {
  description = "Set this variable to true if you want to create a role for AWS CodeDeploy"
  type        = bool
  default     = false
}

variable "create_codebuild_policy" {
  description = "Set this variable to true if you want to create a policy for Codebuild"
  type        = bool
  default     = false
}

variable "create_policy" {
  description = "Set this variable to true if you want to create an IAM Policy"
  type        = bool
  default     = false
}

variable "attach_to" {
  description = "The ARN or role name to attach the policy created"
  type        = string
  default     = ""
}

variable "ecr_repositories" {
  description = "The ECR repositories to which grant IAM access"
  type        = list(string)
  default     = ["*"]
}

variable "code_build_projects" {
  description = "The Code Build projects to which grant IAM access"
  type        = list(string)
  default     = ["*"]
}

variable "code_commit_repositories" {
  description = "The Code Commit Repositories"
  type        = list(string)
  default     = ["*"]
}

variable "code_deploy_resources" {
  description = "The Code Deploy applications and deployment groups to which grant IAM access"
  type        = list(string)
  default     = ["*"]
}

variable "database" {
  description = "The name of the database to which grant IAM access"
  type        = list(string)
  default     = ["*"]
}

variable "s3_bucket_assets" {
  description = "The name of the S3 bucket to which grant IAM access"
  type        = list(string)
  default     = ["*"]
}
