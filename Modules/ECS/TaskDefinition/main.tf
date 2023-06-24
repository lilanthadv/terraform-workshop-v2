/*====================================
  AWS ECS Task definition
=====================================*/

locals {
  container_name = "${var.service.resource_name_prefix}-container"
}

# AWS ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.service.resource_name_prefix}-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      "name" : "${local.container_name}",
      "image" : "${var.docker_repo}",
      "cpu" : 0,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.container_port,
          "hostPort" : var.host_port
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "secretOptions" : null,
        "options" : {
          "awslogs-group" : "/ecs/${var.service.resource_name_prefix}-${var.name}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
        }
      },
      environment = [
        { name = "ACCESS_KEY", value = var.access_key},
        { name = "COGNITO_ACCESS_KEY", value =  var.cognito_access_key },
        { name = "COGNITO_CLIENT_ID", value =  var.cognito_client_id },
        { name = "COGNITO_DOMAIN", value =  var.cognito_domain },
        { name = "COGNITO_REDIRECT_URI", value =  var.cognito_redirect_uri },
        { name = "COGNITO_REGION", value =  var.cognito_region},
        { name = "COGNITO_SECRET_KEY", value =  var.cognito_secret_key },
        { name = "COGNITO_USER_POOL_ID", value = var.cognito_user_pool_id },
        { name = "DATABASE_URL", value =  var.database_url }
      ],
    }
  ])

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
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
  }
}
