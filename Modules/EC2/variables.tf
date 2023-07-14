variable "instance_name" {
  type        = string
  description = "The Instance Name"

}

variable "instance_description" {
  type        = string
  description = "The Instance Description"
}

variable "custom_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = null
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
  description = "EC2 Instance key_pair_name"
}

variable "ec2_key_pair_include_public_key" {
  type        = bool
  description = "EC2 Key Pair Include Public Key"
  default     = true
}

variable "ec2_eip_domain" {
  type        = string
  description = "EC2 EIP Domain"
  default     = "vpc"
}
