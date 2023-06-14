/*==========================
      AWS ECS Service
===========================*/

resource "aws_ecs_service" "ecs_service" {
  name                              = "${var.app_name}-${var.name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = var.arn_task_definition
  desired_count                     = var.desired_tasks
  health_check_grace_period_seconds = 10
  launch_type                       = "FARGATE"

  network_configuration {
    security_groups = [var.arn_security_group]
    subnets         = [var.subnets_id[0], var.subnets_id[1]]
  }

  load_balancer {
    target_group_arn = var.arn_target_group
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }

}
