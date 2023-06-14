/*====================================
      AWS ECS Task definition
=====================================*/

locals {
  container_name = "${var.app_name}-container"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.app_name}-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = <<DEFINITION
    [
      {
        "logConfiguration": {
            "logDriver": "awslogs",
            "secretOptions": null,
            "options": {
              "awslogs-group": "/ecs/${var.app_name}-${var.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          },
        "cpu": 0,
        "image": "${var.docker_repo}",
        "name": "${local.container_name}",
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": ${var.container_port},
            "hostPort": ${var.container_port}
          }
        ]
        }
    ]
    DEFINITION

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}

# CloudWatch Logs groups to store ecs-containers logs
resource "aws_cloudwatch_log_group" "TaskDF-Log_Group" {
  name              = "/ecs/${var.app_name}-${var.name}"
  retention_in_days = 30

  tags = {
    Name        = "/ecs/${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}
