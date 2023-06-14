variable "app_name" {
  type        = string
  description = "The application name"
}

variable "app_version" {
  type        = string
  description = "The application version"
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "name" {
  description = "The name of your security resource"
  type        = string
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
