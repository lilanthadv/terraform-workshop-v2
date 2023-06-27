variable "app_name" {
  type        = string
  description = "The application name"
}

variable "app_version" {
  type        = string
  description = "The application version of the deployment"
}

variable "environment" {
  type        = string
  description = "The environment of the deployment"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

# DB
variable "database_name" {
  type        = string
  description = "Database name"
}

variable "database_schema" {
  type        = string
  description = "Database schema"
}

variable "master_username" {
  type        = string
  description = "Database master username"
}

variable "master_password" {
  type        = string
  description = "Database master password"
}

variable "iam_role_name" {
  description = "The name of the IAM Role for each service"
  type        = map(string)
  default = {
    devops        = "devops-role"
    ecs           = "ecs-task-excecution-role"
    ecs_task_role = "ecs-task-role"
    codedeploy    = "codedeploy-role"
  }
}

variable "docker_image_url" {
  type        = string
  description = "ECS Task Definition Docker Image URL"
}

variable "container_port" {
  type        = number
  description = "ECS Task Definition Container port"
}

variable "host_port" {
  type        = number
  description = "ECS Task Definition Host port"
}

variable "cpu" {
  type        = string
  description = "ECS Task Definition cpu"
}

variable "memory" {
  type        = string
  description = "ECS Task Definition memory"
}

variable "access_key" {
  description = "Access key"
  type        = string
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
}

variable "git_source_type" {
  description = "Git Source Type"
  type        = string
}

variable "git_repository_url" {
  description = "Git Repository URL"
  type        = string
}

variable "git_connection_arn" {
  description = "Git Connection ARN"
  type        = string
}

variable "git_repository_id" {
  description = "Git Repository Id"
  type        = string
}

variable "git_branch_name" {
  description = "Git Branch Name"
  type        = string
}
