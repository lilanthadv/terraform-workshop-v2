variable "autoscaling_name" {
  description = "Autoscaling Name"
  type        = string
}

variable "autoscaling_description" {
  type        = string
  description = "Autoscaling Description"
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

variable "custom_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = null

}
