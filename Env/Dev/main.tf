# Provider
provider "aws" {
  region = var.region
}

# Get Region Available Zones
data "aws_availability_zones" "az_availables" {
  state = "available"
}

locals {
  app_name           = "${var.app_name}-${var.environment}"
  availability_zones = data.aws_availability_zones.az_availables.names
}

# Networking module
module "networking" {
  source             = "../../Modules/Networking"
  app_name           = local.app_name
  app_version        = var.app_version
  environment        = var.environment
  name               = "vpc"
  availability_zones = local.availability_zones
}

# Creating Security Group for Database
module "security_group_db" {
  source      = "../../Modules/SecurityGroup"
  app_name    = local.app_name
  app_version = var.app_version
  environment = var.environment
  name        = "db-sg"
  description = "Controls access to the DB"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = 5432
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
    }, {
    protocol        = "tcp"
    ingress_port    = 5432
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [module.security_group_ecs_task.id]
  }]
}

# Database module
module "database" {
  source               = "../../Modules/Database"
  app_name             = local.app_name
  app_version          = var.app_version
  environment          = var.environment
  name                 = "db-cluster"
  availability_zones   = local.availability_zones
  subnets              = module.networking.private_subnets
  security_groups      = [module.security_group_db.id]
  engine               = "aurora-postgresql"
  engine_version       = "13.6"
  engine_mode          = "provisioned"
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = var.master_password
  port                 = 5432
  deletion_protection  = false
  skip_final_snapshot  = true
  enable_http_endpoint = true
  # Scaling Configuration
  max_capacity = 4.0
  min_capacity = 2.0
}

# # SQS module
# module "sqs" {
#   source                      = "../../Modules/SQS"
#   app_name                    = local.app_name
#   app_version                 = var.app_version
#   environment                 = var.environment
#   name                        = "queue.fifo"
#   fifo_queue                  = true
#   deduplication_scope         = "messageGroup"
#   fifo_throughput_limit       = "perMessageGroupId"
#   visibility_timeout_seconds  = 30
#   delay_seconds               = 0
#   max_message_size            = 256000
#   message_retention_seconds   = 345600
#   receive_wait_time_seconds   = 1
#   content_based_deduplication = false
# }

# Creating Target Group for the ALB
module "target_group" {
  source              = "../../Modules/ALB"
  app_name            = local.app_name
  app_version         = var.app_version
  environment         = var.environment
  name                = "alb-tg"
  create_target_group = true
  port                = 80
  protocol            = "HTTP"
  vpc                 = module.networking.vpc
  tg_type             = "ip"
  health_check_path   = "/"
  health_check_port   = 80
}

# Creating Security Group for the ALB
module "security_group_alb" {
  source      = "../../Modules/SecurityGroup"
  app_name    = local.app_name
  app_version = var.app_version
  environment = var.environment
  name        = "alb-sg"
  description = "Controls access to the ALB"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = 80
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

# Creating Server Application ALB
module "alb" {
  source         = "../../Modules/ALB"
  app_name       = local.app_name
  app_version    = var.app_version
  environment    = var.environment
  name           = "alb"
  create_alb     = true
  subnets        = module.networking.public_subnets
  security_group = module.security_group_alb.id
  target_group   = module.target_group.arn_tg
}

# ECS Role
module "ecs_role" {
  source             = "../../Modules/IAM"
  app_name           = local.app_name
  app_version        = var.app_version
  environment        = var.environment
  create_ecs_role    = true
  name               = var.iam_role_name["ecs"]
  name_ecs_task_role = var.iam_role_name["ecs_task_role"]
  database           = ["*"]
  # database           = [module.database.database_arn]
}

# Creating a IAM Policy for role
module "ecs_role_policy" {
  source        = "../../Modules/IAM"
  app_name      = local.app_name
  app_version   = var.app_version
  environment   = var.environment
  name          = "ecs-rp"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# # Creating ECR Repository to store Docker Images
# module "ecr" {
#   source      = "../../Modules/ECR"
#   app_name    = local.app_name
#   app_version = var.app_version
#   environment = var.environment
#   name        = "repo"
# }

# Creating ECS Task Definition
module "ecs_taks_definition" {
  source             = "../../Modules/ECS/TaskDefinition"
  app_name           = local.app_name
  app_version        = var.app_version
  environment        = var.environment
  name               = "td"
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = 256
  memory             = "512"
  docker_repo        = "048102882581.dkr.ecr.ap-southeast-2.amazonaws.com/testapp4"
  # docker_repo        = module.ecr.ecr_repository_url
  region         = var.region
  container_port = 80
}

# Creating a Security Group for ECS TASKS
module "security_group_ecs_task" {
  source      = "../../Modules/SecurityGroup"
  app_name    = local.app_name
  app_version = var.app_version
  environment = var.environment
  name        = "ecs-task-sg"
  description = "Controls access to the server ECS task"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = 80
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [module.security_group_alb.id]
  }]
}

# Creating ECS Cluster 
module "ecs_cluster" {
  source      = "../../Modules/ECS/Cluster"
  app_name    = local.app_name
  app_version = var.app_version
  environment = var.environment
  name        = "ecs-cluster"
}

# Creating ECS Service
module "ecs_service" {
  depends_on          = [module.alb]
  source              = "../../Modules/ECS/Service"
  app_name            = local.app_name
  app_version         = var.app_version
  environment         = var.environment
  name                = "service"
  desired_tasks       = 1
  arn_security_group  = module.security_group_ecs_task.id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group.arn_tg
  arn_task_definition = module.ecs_taks_definition.arn_task_definition
  subnets             = module.networking.private_subnets
  container_port      = 80
  container_name      = module.ecs_taks_definition.container_name
}

# Creating ECS Autoscaling policies
module "ecs_autoscaling" {
  depends_on   = [module.ecs_service]
  source       = "../../Modules/ECS/Autoscaling"
  app_name     = local.app_name
  app_version  = var.app_version
  environment  = var.environment
  name         = "autoscaling"
  cluster_name = module.ecs_cluster.ecs_cluster_name
  service_name = module.ecs_service.ecs_service_name
  min_capacity = 1
  max_capacity = 4
}


