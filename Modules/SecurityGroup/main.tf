/*================================
      AWS Security group
=================================*/

# Create AWS Security Group
resource "aws_security_group" "sg" {
  name        = var.security_group_name
  description = var.security_group_description
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

  tags = merge(
    {
      Name        = var.security_group_name
      Description = var.security_group_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
