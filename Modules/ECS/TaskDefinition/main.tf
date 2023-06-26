/*====================================
  AWS ECS Task definition
=====================================*/

locals {
  container_name = "${var.service.resource_name_prefix}-container"
}

# AWS ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.service.resource_name_prefix}-${var.name}"
  network_mode             = var.ecs_task_definition_network_mode
  requires_compatibilities = var.ecs_task_definition_requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      "name" : local.container_name,
      "image" : var.docker_repo,
      "cpu" : var.ecs_task_definition_container_definitions_cpu,
      "networkMode" : var.ecs_task_definition_container_definitions_networkMode,
      "portMappings" : [
        {
          "containerPort" : var.container_port,
          "hostPort" : var.host_port
        }
      ],
      "logConfiguration" : {
        "logDriver" : var.ecs_task_definition_container_definitions_logConfiguration_logDriver,
        "secretOptions" : var.ecs_task_definition_container_definitions_logConfiguration_secretOptions,
        "options" : {
          "awslogs-group" : "/ecs/${var.service.resource_name_prefix}-${var.name}",
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : var.ecs_task_definition_container_definitions_logConfiguration_options_awslogs_stream_prefix
        }
      },
      environment = var.environment_variables
    }
  ])

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

# CloudWatch Logs groups to store ecs-containers logs
resource "aws_cloudwatch_log_group" "TaskDF-Log_Group" {
  name              = "/ecs/${var.service.resource_name_prefix}-${var.name}"
  retention_in_days = 30

  tags = {
    Name        = "/ecs/${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}
