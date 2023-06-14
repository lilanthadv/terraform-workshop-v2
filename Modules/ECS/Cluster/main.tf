/*=============================
        AWS ECS Cluster
===============================*/

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-${var.name}"

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}
