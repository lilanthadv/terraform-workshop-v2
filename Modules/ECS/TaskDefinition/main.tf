/*====================================
  AWS ECS Task definition
=====================================*/

locals {
  container_name = "${var.taks_definition_name}-container"
}

# AWS ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.taks_definition_name
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
          "awslogs-group" : "/ecs/${var.taks_definition_name}",
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : var.ecs_task_definition_container_definitions_logConfiguration_options_awslogs_stream_prefix
        }
      },
      environment = var.environment_variables
    }
  ])

  tags = merge(
    {
      Name        = var.taks_definition_name
      Description = var.taks_definition_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# CloudWatch Logs groups to store ecs-containers logs
resource "aws_cloudwatch_log_group" "ecs_task_definition_log_group" {
  name              = "/ecs/${var.taks_definition_name}"
  retention_in_days = 30

  tags = merge(
    {
      Name        = "/ecs/${var.taks_definition_name}"
      Description = "${var.taks_definition_description}, Cloudwatch Log Group"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
