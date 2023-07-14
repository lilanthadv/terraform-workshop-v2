/*==========================
  AWS ECS Service
===========================*/

# AWS ECS Service
resource "aws_ecs_service" "ecs_service" {
  name                              = var.service_name
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

  tags = merge(
    {
      Name        = var.service_name
      Description = var.service_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
