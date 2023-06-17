data "aws_key_pair" "instance_key" {
  key_name           = var.key_pair_name
  include_public_key = true
}

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
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}

resource "aws_eip" "bastion_host" {
  count    = var.associate_elastic_ip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.instance.id

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}
