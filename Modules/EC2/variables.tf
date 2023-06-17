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
  type        = string
  description = "The name of your security resource"

}

variable "ami" {
  type        = string
  description = "EC2 instance ami"

}

variable "instance_type" {
  type        = string
  description = "EC2 instance instance_type"

  default = "t2.micro"
}

variable "subnet_id" {
  type        = string
  description = "EC2 instance subnet_id"

}

variable "security_groups" {
  type        = list(string)
  description = "EC2 instance security groups"

}

variable "associate_public_ip_address" {
  type        = bool
  description = "EC2 instance associate_public_ip_address"

}

variable "associate_elastic_ip" {
  type        = bool
  description = "EC2 instance associate elastic ip"

}

variable "availability_zone" {
  type        = string
  description = "EC2 instance availability_zone"
}

variable "user_data" {
  type        = string
  description = "EC2 instance user_data"
}

variable "key_pair_name" {
  type        = string
  description = "EC2 instance key_pair_name"
}
