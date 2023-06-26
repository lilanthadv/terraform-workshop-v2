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

variable "min_capacity" {
  description = "The minimal number of ECS tasks to run"
  type        = number
}

variable "max_capacity" {
  description = "The maximal number of ECS tasks to run"
  type        = number
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "appautoscaling_target_scalable_dimension" {
  description = "App Auto Scaling Target Scalable Dimension"
  type        = string
  default     = "ecs:service:DesiredCount"
}

variable "appautoscaling_target_service_namespace" {
  description = "App Auto Scaling Target Service Namespace"
  type        = string
  default     = "ecs"
}
