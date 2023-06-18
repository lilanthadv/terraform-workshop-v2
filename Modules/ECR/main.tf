/*=========================================
      AWS Elastic Container Repository
==========================================*/

# AWS ECR Repository
resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${var.service.resource_name_prefix}-${var.name}"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}
