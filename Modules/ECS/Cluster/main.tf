/*=============================
        AWS ECS Cluster
===============================*/

# AWS ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.service.resource_name_prefix}-${var.name}"

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}
