/*====================================
  AWS EC2 Instance & Elastic IP
======================================*/

# Key Pair for EC2 Instance
data "aws_key_pair" "instance_key" {
  key_name           = var.key_pair_name
  include_public_key = var.ec2_key_pair_include_public_key
}

# Create AWS Instance
resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = var.security_groups
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.availability_zone

  user_data = var.user_data

  key_name = data.aws_key_pair.instance_key.key_name

  tags = merge(
    {
      Name        = var.instance_name
      Description = var.instance_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create AWS EIP
resource "aws_eip" "bastion_host" {
  count    = var.associate_elastic_ip ? 1 : 0
  domain   = var.ec2_eip_domain
  instance = aws_instance.instance.id

  tags = merge(
    {
      Name        = "${var.instance_name}-eip"
      Description = "${var.instance_description}, Elastic IP"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
