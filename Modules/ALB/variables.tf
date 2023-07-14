variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null
}

variable "create_alb" {
  description = "Set to true to create an ALB"
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "ALB Name"
  type        = string
  default     = ""
}

variable "alb_description" {
  description = "ALB Description"
  type        = string
  default     = ""
}

variable "target_group" {
  description = "The ARN of the created target group"
  type        = string
  default     = ""
}

variable "enable_https" {
  description = "Set to true to create a HTTPS listener"
  type        = bool
  default     = false
}

variable "create_target_group" {
  description = "Set to true to create a Target Group"
  type        = bool
  default     = false
}

variable "target_group_name" {
  description = "ALB Target Group Name"
  type        = string
  default     = ""
}

variable "target_group_description" {
  description = "ALB Target Group Description"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "Subnets IDs for ALB"
  type        = list(any)
  default     = []
}

variable "security_group" {
  description = "Security group ID for the ALB"
  type        = string
  default     = ""
}

variable "port" {
  description = "The port that the targer group will use"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "The protocol that the target group will use"
  type        = string
  default     = ""
}

variable "vpc" {
  description = "VPC ID for the Target Group"
  type        = string
  default     = ""
}

variable "tg_type" {
  description = "Target Group Type (instance, IP, lambda)"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "The path in which the ALB will send health checks"
  type        = string
  default     = ""
}

variable "health_check_port" {
  description = "The port to which the ALB will send health checks"
  type        = number
  default     = 80
}

variable "ssl_certificate_arn" {
  description = "SSL Certificate ARN"
  type        = string
  default     = null
}

variable "load_balancer_type" {
  description = "Load Balancer Type"
  type        = string
  default     = "application"
}

variable "load_balancer_internal" {
  description = "Load Balancer Internal"
  type        = bool
  default     = false
}

variable "load_balancer_enable_http2" {
  description = "Load Balancer Enable http2"
  type        = bool
  default     = true
}

variable "load_balancer_idle_timeout" {
  description = "Load Balancer Idle Timeout"
  type        = number
  default     = 30
}

variable "alb_target_group_deregistration_delay" {
  description = "ALB Target Group Deregistration Delay"
  type        = number
  default     = 5
}

variable "alb_target_group_health_check_enabled" {
  description = "ALB Target Group Health Check Enabled"
  type        = bool
  default     = true
}

variable "alb_target_group_health_check_interval" {
  description = "ALB Target Group Health Check Interval"
  type        = number
  default     = 15
}

variable "alb_target_group_health_check_timeout" {
  description = "ALB Target Group Health Check Timeout"
  type        = number
  default     = 10
}

variable "alb_target_group_health_check_healthy_threshold" {
  description = "ALB Target Group Health Check Healthy Threshold"
  type        = number
  default     = 2
}

variable "alb_target_group_health_check_unhealthy_threshold" {
  description = "ALB Target Group Health Check Unhealthy Threshold"
  type        = number
  default     = 3
}

variable "alb_target_group_health_check_matcher" {
  description = "ALB Target Group Health Check Matcher"
  type        = string
  default     = "200"
}
