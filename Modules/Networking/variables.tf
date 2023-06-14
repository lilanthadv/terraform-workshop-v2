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

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones"
}

variable "public_subnet_name" {
  type        = string
  description = "The public subnet name"
  default     = "public-subnet"
}

variable "private_subnet_name" {
  type        = string
  description = "The private subnet name"
  default     = "private-subnet"
}
