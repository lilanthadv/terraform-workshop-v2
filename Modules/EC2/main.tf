/*====================================
  AWS EC2 Instance & Elastic IP
======================================*/

# Key Pair for EC2 Instance
data "aws_key_pair" "instance_key" {
  key_name           = var.key_pair_name
  include_public_key = true
}

# AWS Instance
resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = var.security_groups
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.availability_zone

  user_data = var.user_data

  key_name = data.aws_key_pair.instance_key.key_name

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}

# AWS EIP
resource "aws_eip" "bastion_host" {
  count    = var.associate_elastic_ip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.instance.id

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-eip"
    Description = "${var.description} Elastic IP"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}
