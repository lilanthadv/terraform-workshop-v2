variable "vpc_name" {
  description = "The VPC name"
  type        = string
}

variable "vpc_description" {
  type        = string
  description = "The VPC description"
}

variable "custom_tags" {
  description = "Tags for the VPC"
  type        = map(string)
  default     = null
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones"
}
