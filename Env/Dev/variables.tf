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

# SQS Variables
variable "sqs_fifo_queue" {
  type        = bool
  description = "SQS Fifo Queue"
  default     = true
}

variable "sqs_deduplication_scope" {
  type        = string
  description = "SQS Deduplication Scope"
  default     = "messageGroup"
}

variable "sqs_fifo_throughput_limit" {
  type        = string
  description = "SQS Fifo Throughput Limit"
  default     = "perMessageGroupId"
}

variable "sqs_visibility_timeout_seconds" {
  type        = number
  description = "SQS Visibility Timeout Seconds"
  default     = 30
}

variable "sqs_delay_seconds" {
  type        = number
  description = "SQS Delay Seconds"
  default     = 0
}

variable "sqs_max_message_size" {
  type        = number
  description = "SQS Max Message Size"
  default     = 256000
}

variable "sqs_message_retention_seconds" {
  type        = number
  description = "SQS Message Retention Seconds"
  default     = 345600
}

variable "sqs_receive_wait_time_seconds" {
  type        = number
  description = "SQS Receive Wait Time Seconds"
  default     = 1
}

variable "sqs_content_based_deduplication" {
  type        = bool
  description = "SQS Content Based Deduplication"
  default     = false
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
  default     = true
}

variable "ecs_alb_ssl_certificate_arn" {
  type        = string
  description = "ECS ALB SSL Certificate ARN"
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

variable "ecs_taks_definition_access_key" {
  description = "Access key"
  type        = string
}

variable "ecs_taks_definition_secret_key" {
  description = "Secret Key"
  type        = string
}

variable "ecs_taks_definition_env_cognito_redirect_uri" {
  description = "ECS Taks Definition ENV Cognito Redirect URL"
  type        = string
}

variable "ecs_taks_definition_env_front_end_url" {
  description = "ECS Taks Definition ENV Front End URL"
  type        = string
}

variable "ecs_taks_definition_env_ses_email" {
  description = "ECS Taks Definition ENV SES email"
  type        = string
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

# Cognito User Pool
variable "cognito_lambda_config_pre_sign_up_arn" {
  description = "Cognito Lambda Config Pre Sign Up ARN"
  type        = string
}

variable "cognito_lambda_config_custom_message_arn" {
  description = "Cognito Lambda Custom Message ARN"
  type        = string
}

variable "cognito_google_configurations_client_id" {
  description = "Cognito Google Configurations Client Id"
  type        = string
}

variable "cognito_google_configurations_client_secret" {
  description = "Cognito Google Configurations Client Secret"
  type        = string
}

variable "cognito_microsoft_configuration_client_id" {
  description = "Cognito Microsoft Configurations Client Id"
  type        = string
}

variable "cognito_microsoft_configuration_client_secret" {
  description = "Cognito Microsoft Configurations Client Secret"
  type        = string
}

variable "cognito_microsoft_configuration_oidc_issuer" {
  description = "Cognito Microsoft Configurations OIDC Issuer"
  type        = string
}

variable "cognito_microsoft_configuration_authorize_scopes" {
  description = "Cognito Microsoft Configurations Authorize Scopes"
  type        = string
  default     = "profile email openid"
}

variable "cognito_microsoft_configuration_attributes_request_method" {
  description = "Cognito Microsoft Configurations Attributes Request Method"
  type        = string
  default     = "GET"
}

variable "cognito_client_configuration_callback_urls" {
  description = "Cognito Client Configuration Callback URLS"
  type        = list(string)
}

variable "cognito_client_configuration_logout_urls" {
  description = "Cognito Client Configuration Logout URLS"
  type        = list(string)
}

# S3 Bucket for CodePipeline
variable "s3_bucket_pipeline_artifact_store_force_destroy" {
  description = "S3 Bucket Pipeline Artifact Store Force Destroy"
  type        = bool
  default     = true
}

# Server App Git
variable "server_app_git_connection_arn" {
  description = "Git Connection ARN for Server App"
  type        = string
}

variable "server_app_git_source_type" {
  description = "Git Source Type for Server App"
  type        = string
}

variable "server_app_git_repository_url" {
  description = "Git Repository URL for Server App"
  type        = string
}

variable "server_app_git_repository_id" {
  description = "Git Repository Id for Server App"
  type        = string
}

variable "server_app_git_branch_name" {
  description = "Git Branch Name for Server App"
  type        = string
}

# Client App Git
variable "client_app_git_connection_arn" {
  description = "Git Connection ARN for Client App"
  type        = string
}

variable "client_app_git_source_type" {
  description = "Git Source Type for Client App"
  type        = string
}

variable "client_app_git_repository_url" {
  description = "Git Repository URL for Client App"
  type        = string
}

variable "client_app_git_repository_id" {
  description = "Git Repository Id for Client App"
  type        = string
}

variable "client_app_git_branch_name" {
  description = "Git Branch Name for Client App"
  type        = string
}

# Client App Environment variables
variable "codebuild_client_app_env_api_url" {
  description = "Front end codebuild_client_app_env_API_URL variable value"
  type        = string
}

variable "codebuild_client_app_env_front_end_uri" {
  description = "Front end codebuild_client_app_env_FRONT_END_URI variable value"
  type        = string
}

variable "codebuild_client_app_env_stripe_key" {
  description = "Front end codebuild_client_app_env_STRIPE_KEY variable value"
  type        = string
}

variable "codebuild_client_app_env_pdf_service_url" {
  description = "Front end codebuild_client_app_env_PDF_SERVICE_URL variable value"
  type        = string
}

variable "codebuild_client_app_env_word_service_url" {
  description = "Front end codebuild_client_app_env_WORD_SERVICE_URL variable value"
  type        = string
}

variable "codebuild_client_app_env_syncfusion_key" {
  description = "Front end codebuild_client_app_env_SYNCFUSION_KEY variable value"
  type        = string
}
