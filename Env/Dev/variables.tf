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

variable "backend_git_connection_arn" {
  description = "Git Connection ARN for Backend"
  type        = string
}

variable "backend_git_source_type" {
  description = "Git Source Type for Backend"
  type        = string
}

variable "backend_git_repository_url" {
  description = "Git Repository URL for Backend"
  type        = string
}

variable "backend_git_repository_id" {
  description = "Git Repository Id for Backend"
  type        = string
}

variable "backend_git_branch_name" {
  description = "Git Branch Name for Backend"
  type        = string
}


variable "frontend_git_connection_arn" {
  description = "Git Connection ARN for Frontend"
  type        = string
}

variable "frontend_git_source_type" {
  description = "Git Source Type for Frontend"
  type        = string
}

variable "frontend_git_repository_url" {
  description = "Git Repository URL for Frontend"
  type        = string
}

variable "frontend_git_repository_id" {
  description = "Git Repository Id for Frontend"
  type        = string
}

variable "frontend_git_branch_name" {
  description = "Git Branch Name for Frontend"
  type        = string
}

# Frontend Environment variables
variable "react_app_api_url" {
  description = "Front end REACT_APP_API_URL variable value"
  type        = string
}

variable "react_app_front_end_uri" {
  description = "Front end REACT_APP_FRONT_END_URI variable value"
  type        = string
}

variable "react_app_stripe_key" {
  description = "Front end REACT_APP_STRIPE_KEY variable value"
  type        = string
}

variable "react_app_pdf_service_url" {
  description = "Front end REACT_APP_PDF_SERVICE_URL variable value"
  type        = string
}

variable "react_app_word_service_url" {
  description = "Front end REACT_APP_WORD_SERVICE_URL variable value"
  type        = string
}

variable "react_app_syncfusion_key" {
  description = "Front end REACT_APP_SYNCFUSION_KEY variable value"
  type        = string
}