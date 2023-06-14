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

variable "description" {
  description = "A description of the purpose"
  type        = string
}

variable "vpc" {
  description = "The ID of the VPC where the security group will take place"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    protocol        = string
    ingress_port    = number
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  default = []
}

variable "egress_port" {
  description = "Number of the port to open in the egress rules"
  type        = number
  default     = 0
}

variable "cidr_blocks_egress" {
  description = "An ingress block of CIDR to grant access to"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}
