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

# Database Variables
variable "database_engine" {
  type        = string
  description = "Database Engine"
  default     = "aurora-postgresql"
}

variable "database_engine_version" {
  type        = string
  description = "Database Engine Version"
  default     = "14.6"
}

variable "database_engine_mode" {
  type        = string
  description = "Database Engine Mode"
  default     = "provisioned"
}

variable "database_name" {
  type        = string
  description = "Database name"
}

variable "database_schema" {
  type        = string
  description = "Database schema"
}

variable "database_master_username" {
  type        = string
  description = "Database master username"
}

variable "database_master_password" {
  type        = string
  description = "Database master password"
}

variable "database_port" {
  type        = number
  description = "Database Port"
  default     = 5432
}

variable "database_deletion_protection" {
  type        = bool
  description = "Database Deletion Protection"
  default     = false
}

variable "database_skip_final_snapshot" {
  type        = bool
  description = "Database Skip Final Snapshot"
  default     = true
}

variable "database_enable_http_endpoint" {
  type        = bool
  description = "Database Enable Http Endpoint"
  default     = true
}

variable "database_storage_encrypted" {
  type        = bool
  description = "Database Storage Encrypted"
  default     = true
}

# Database Scaling Configuration
variable "database_scaling_min_capacity" {
  type        = number
  description = "Database Scaling Min Capacity"
  default     = 1.0
}

variable "database_scaling_max_capacity" {
  type        = number
  description = "Database Scaling Max Capacity"
  default     = 2.0
}

# Bastion Host Variables
variable "bastion_host_instance_type" {
  type        = string
  description = "Bastion Host Instance Type"
  default     = "t2.micro"
}

variable "bastion_host_associate_public_ip_address" {
  type        = bool
  description = "Bastion Host Associate Public IP Address"
  default     = true
}

variable "bastion_host_associate_elastic_ip" {
  type        = bool
  description = "Bastion Host Associate Elastic IP"
  default     = true
}

variable "bastion_host_key_pair_name" {
  type        = string
  description = "Bastion Host Key Pair Name"
}

# Roles
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

# ECS Variables
# ECS Target Group Variables
variable "ecs_target_group_protocol" {
  type        = string
  description = "ECS Target Group Protocol"
  default     = "HTTP"
}

variable "ecs_target_group_tg_type" {
  type        = string
  description = "ECS Target Group TG Type"
  default     = "ip"
}

variable "ecs_target_group_health_check_path" {
  type        = string
  description = "ECS Target Group Health Check Path"
  default     = "/health"
}

# ECS ALB Variables
variable "ecs_alb_enable_https" {
  type        = bool
  description = "ECS ALB Enable HTTPS"
  default     = false
}

variable "ecs_alb_ssl_certificate_arn" {
  type        = string
  description = "ECS ALB SSL Certificate ARN"
  default     = null
}

# ECS Task Definition Variables
variable "ecs_taks_definition_host_port" {
  type        = number
  description = "ECS Task Definition Host port"
}

variable "ecs_taks_definition_cpu" {
  type        = string
  description = "ECS Task Definition cpu"
}

variable "ecs_taks_definition_memory" {
  type        = string
  description = "ECS Task Definition memory"
}

# ECS Service
variable "ecs_service_container_port" {
  type        = number
  description = "ECS Service Container port"
}

variable "ecs_service_desired_tasks" {
  description = "ECS Service Desired Tasks"
  type        = number
  default     = 1
}

# ECS Autoscaling
variable "ecs_autoscaling_min_capacity" {
  description = "ECS Autoscaling Min Capacity"
  type        = number
  default     = 1
}

variable "ecs_autoscaling_max_capacity" {
  description = "ECS Autoscaling Max Capacity"
  type        = number
  default     = 4
}

# S3 Bucket for CodePipeline
variable "s3_bucket_pipeline_artifact_store_force_destroy" {
  description = "S3 Bucket Pipeline Artifact Store Force Destroy"
  type        = bool
  default     = true
}

# Git
variable "git_source_type" {
  description = "Git Source Type"
  type        = string
  default     = "CODECOMMIT"
}

variable "git_repository_url" {
  description = "Git Repository URL"
  type        = string
}

variable "git_repository_name" {
  description = "Git Repository Name"
  type        = string
}

variable "git_repository_branch" {
  description = "Git Branch Name for Codepipeline"
  type        = string
  default = "main"
}
