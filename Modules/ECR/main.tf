/*=========================================
      AWS Elastic Container Repository
==========================================*/

resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${var.app_name}-${var.name}"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}
