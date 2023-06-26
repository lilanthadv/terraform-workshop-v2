/*==========================
  AWS ECS Service
===========================*/

# AWS ECS Service
resource "aws_ecs_service" "ecs_service" {
  name                              = "${var.service.resource_name_prefix}-${var.name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = var.arn_task_definition
  desired_count                     = var.desired_tasks
  health_check_grace_period_seconds = var.ecs_service_health_check_grace_period_seconds
  launch_type                       = var.ecs_service_launch_type

  network_configuration {
    security_groups = [var.arn_security_group]
    subnets         = [var.subnets[0], var.subnets[1]]
  }

  load_balancer {
    target_group_arn = var.arn_target_group
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = var.ecs_service_deployment_controller_type
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}
