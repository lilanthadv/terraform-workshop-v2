/*================================
      AWS Security group
=================================*/

# AWS Security Group
resource "aws_security_group" "sg" {
  name        = "${var.service.resource_name_prefix}-${var.name}"
  description = var.description
  vpc_id      = var.vpc

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      protocol        = ingress.value.protocol
      from_port       = ingress.value.ingress_port
      to_port         = ingress.value.ingress_port
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_egress
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}
