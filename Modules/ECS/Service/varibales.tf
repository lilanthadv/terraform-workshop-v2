variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "service_description" {
  type        = string
  description = "Service description"
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null

}

variable "desired_tasks" {
  description = "The minumum number of tasks to run in the service"
  type        = string
}

variable "arn_security_group" {
  description = "ARN of the security group for the tasks"
  type        = string
}

variable "ecs_cluster_id" {
  description = "The ECS cluster ID in which the resources will be created"
  type        = string
}

variable "arn_target_group" {
  description = "The ARN of the AWS Target Group to put the ECS task"
  type        = string
}

variable "arn_task_definition" {
  description = "The ARN of the Task Definition to use to deploy the tasks"
  type        = string
}

variable "subnets" {
  description = "Subnet ID in which ecs will deploy the tasks"
  type        = list(string)
}

variable "container_port" {
  description = "The port that the container will listen request"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "ecs_service_health_check_grace_period_seconds" {
  description = "ECS Service Health Check Grace Period Seconds"
  type        = number
  default     = 10
}

variable "ecs_service_launch_type" {
  description = "ECS Service Launch Type"
  type        = string
  default     = "FARGATE"
}

variable "ecs_service_deployment_controller_type" {
  description = "ECS Service Deployment Controller Type"
  type        = string
  default     = "ECS"
}
