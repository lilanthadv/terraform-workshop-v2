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
  description = "The name for the Role"
  type        = string
}

variable "description" {
  type        = string
  description = "The description"
}

variable "execution_role_arn" {
  description = "The IAM ARN role that the ECS task will use to call other AWS services"
  type        = string
}

variable "task_role_arn" {
  description = "The IAM ARN role that the ECS task will use to call other AWS services"
  type        = string
  default     = null
}

variable "cpu" {
  description = "The CPU value to assign to the container, read AWS documentation for available values"
  type        = string
}

variable "memory" {
  description = "The MEMORY value to assign to the container, read AWS documentation to available values"
  type        = string
}

variable "docker_repo" {
  description = "The docker registry URL in which ecs will get the Docker image"
  type        = string
}

variable "region" {
  description = "AWS Region in which the resources will be deployed"
  type        = string
}

variable "container_port" {
  description = "The port that the container will use to listen to requests"
  type        = number
}

variable "host_port" {
  description = "The host port"
  type        = number
}

variable "access_key" {
  description = "Access key"
  type        = string
}

variable "cognito_access_key" {
  description = "Cognito Access key"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito Client ID"
  type        = string
}

variable "cognito_domain" {
  description = "Cognito Domain"
  type        = string
}

variable "cognito_redirect_uri" {
  description = "Cognito Redirect URI"
  type        = string
}

variable "cognito_region" {
  description = "Cognito Region"
  type        = string
}

variable "cognito_secret_key" {
  description = "Cognito Secret Key"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "database_url" {
  description = "Database URL"
  type        = string
}

variable "frontend_url" {
  description = "Frontend URL"
  type        = string
}

variable "jwt_iss" {
  description = "JWT ISS"
  type        = string
}

variable "port" {
  description = "Port"
  type        = string
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
}

variable "ses_email" {
  description = "SES Email"
  type        = string
}

variable "sqs_queue_url" {
  description = "SQS Queue URL"
  type        = string
}
