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

variable "ecs_task_definition_network_mode" {
  description = "ECS Task Definition Network Mode"
  type        = string
  default     = "awsvpc"
}

variable "ecs_task_definition_requires_compatibilities" {
  description = "ECS Task Definition Requires Compatibilities"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "ecs_task_definition_container_definitions_cpu" {
  description = "ECS Task Definition Container Definitions CPU"
  type        = number
  default     = 0
}

variable "ecs_task_definition_container_definitions_networkMode" {
  description = "ECS Task Definition Container Definitions Network Mode"
  type        = string
  default     = "awsvpc"
}

variable "ecs_task_definition_container_definitions_logConfiguration_logDriver" {
  description = "ECS Task Definition Container Definitions logConfiguration logDriver"
  type        = string
  default     = "awslogs"
}

variable "ecs_task_definition_container_definitions_logConfiguration_secretOptions" {
  description = "ECS Task Definition Container Definitions logConfiguration secretOptions"
  type        = string
  default     = null
}

variable "ecs_task_definition_container_definitions_logConfiguration_options_awslogs_stream_prefix" {
  description = "ECS Task Definition Container Definitions logConfiguration options_awslogs stream-prefix"
  type        = string
  default     = "ecs"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
}
