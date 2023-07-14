variable "security_group_name" {
  description = "The Security Group name"
  type        = string
}

variable "security_group_description" {
  description = "The Security Group description"
  type        = string
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null
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
