# Provider
provider "aws" {
  region = var.region
}

# Get Region Available Zones
data "aws_availability_zones" "az_availables" {
  state = "available"
}

# Get User Details
data "aws_caller_identity" "current" {}

# Local Variables
locals {
  app_name           = "${var.app_name}-${var.environment}"
  availability_zones = data.aws_availability_zones.az_availables.names
  username           = split("/", data.aws_caller_identity.current.arn)[1]
  service = {
    app_name             = var.app_name
    app_version          = var.app_version
    app_environment      = var.environment
    user                 = split("/", data.aws_caller_identity.current.arn)[1]
    resource_name_prefix = "${var.app_name}-${var.environment}"
  }
}

# Networking module
module "networking" {
  source             = "../../Modules/Networking"
  service            = local.service
  name               = "vpc"
  description        = "Application VPC"
  availability_zones = local.availability_zones
}

# Creating Security Group for Database
module "security_group_db" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "db-sg"
  description = "Security Group for Database"
  vpc         = module.networking.vpc
  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = 5432
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      protocol        = "tcp"
      ingress_port    = 5432
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [module.security_group_bastion_host.id]
    },
    {
      protocol        = "tcp"
      ingress_port    = 5432
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [module.security_group_ecs_task.id]
    }
  ]
}

# Database module
module "database" {
  source               = "../../Modules/RDS/Serverless/V2"
  service              = local.service
  name                 = "db"
  description          = "Serverless V2 RDS Database"
  availability_zones   = local.availability_zones
  subnets              = module.networking.private_subnets
  security_groups      = [module.security_group_db.id]
  engine               = "aurora-postgresql"
  engine_version       = "14.6"
  engine_mode          = "provisioned"
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = var.master_password
  port                 = 5432
  deletion_protection  = false
  skip_final_snapshot  = true
  enable_http_endpoint = true
  # Scaling Configuration
  max_capacity = 2.0
  min_capacity = 1.0
  # Encryption Configuration
  storage_encrypted = true
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

# Creating Security Group for Bastion Host
module "security_group_bastion_host" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "bastion-host-sg"
  description = "Security Group for Bastion Host"
  vpc         = module.networking.vpc
  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = 22
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      protocol        = "tcp"
      ingress_port    = 5432
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# Creating Bastion Host for DB
module "bastion_host" {
  source                      = "../../Modules/EC2"
  service                     = local.service
  name                        = "bastion-host"
  description                 = "Bastion Host to the connect to the DB"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.networking.public_subnets[0]
  security_groups             = [module.security_group_bastion_host.id]
  associate_public_ip_address = true
  availability_zone           = local.availability_zones[0]
  user_data                   = file("./bastion_host_user_data.sh")
  associate_elastic_ip        = false
  key_pair_name               = "bastion_host_key"
}

# SQS module
module "sqs" {
  source                      = "../../Modules/SQS"
  service                     = local.service
  name                        = "queue.fifo"
  description                 = "SQS service"
  fifo_queue                  = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"
  visibility_timeout_seconds  = 30
  delay_seconds               = 0
  max_message_size            = 256000
  message_retention_seconds   = 345600
  receive_wait_time_seconds   = 1
  content_based_deduplication = false
}

# Creating Target Group for the ALB
module "target_group" {
  source              = "../../Modules/ALB"
  service             = local.service
  name                = "alb-tg"
  description         = "Target Group for the ALB"
  create_target_group = true
  port                = var.host_port
  protocol            = "HTTP"
  vpc                 = module.networking.vpc
  tg_type             = "ip"
  health_check_path   = "/health"
  health_check_port   = var.host_port
}

# Creating Security Group for the ALB
module "security_group_alb" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "alb-sg"
  description = "Security Group for the ALB"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = var.host_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

# Creating Application ALB
module "alb" {
  source         = "../../Modules/ALB"
  service        = local.service
  name           = "alb"
  description    = "Application ALB"
  create_alb     = true
  subnets        = module.networking.public_subnets
  security_group = module.security_group_alb.id
  target_group   = module.target_group.arn_tg
}

# ECS Role
module "ecs_role" {
  source             = "../../Modules/IAM"
  service            = local.service
  name               = var.iam_role_name["ecs"]
  name_ecs_task_role = var.iam_role_name["ecs_task_role"]
  description        = "ECS Role"
  create_ecs_role    = true
  database           = [module.database.database_arn]
}

# Creating a IAM Policy for role
module "ecs_role_policy" {
  source        = "../../Modules/IAM"
  service       = local.service
  name          = "ecs-rp"
  description   = "IAM Policy for role"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# # Creating ECR Repository to store Docker Images
# module "ecr" {
#   source      = "../../Modules/ECR"
#   service     = local.service
#   name        = "repo"
#   description = "ECR Repository to store Docker Images"
# }

# Creating ECS Task Definition
module "ecs_taks_definition" {
  source             = "../../Modules/ECS/TaskDefinition"
  service            = local.service
  name               = "td"
  description        = "ECS Task Definition"
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = var.cpu
  memory             = var.memory
  docker_repo        = var.docker_image_url
  # docker_repo        = module.ecr.ecr_repository_url
  region         = var.region
  container_port = var.container_port
  host_port      = var.host_port
}

# Creating a Security Group for ECS Task
module "security_group_ecs_task" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = var.host_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [module.security_group_alb.id]
  }]
}

# Creating ECS Cluster 
module "ecs_cluster" {
  source      = "../../Modules/ECS/Cluster"
  service     = local.service
  name        = "ecs-cluster"
  description = "ECS Cluster"
}

# Creating ECS Service
module "ecs_service" {
  depends_on          = [module.alb]
  source              = "../../Modules/ECS/Service"
  service             = local.service
  name                = "service"
  description         = "ECS Service"
  desired_tasks       = 1
  arn_security_group  = module.security_group_ecs_task.id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group.arn_tg
  arn_task_definition = module.ecs_taks_definition.arn_task_definition
  subnets             = module.networking.private_subnets
  container_port      = var.host_port
  container_name      = module.ecs_taks_definition.container_name
}

# Creating ECS Autoscaling Policies
module "ecs_autoscaling" {
  depends_on   = [module.ecs_service]
  source       = "../../Modules/ECS/Autoscaling"
  service      = local.service
  name         = "autoscaling"
  description  = "ECS Autoscaling Policies"
  cluster_name = module.ecs_cluster.ecs_cluster_name
  service_name = module.ecs_service.ecs_service_name
  min_capacity = 1
  max_capacity = 4
}

#S3 Bucket
module "s3" {
  source            = "../../Modules/S3"
  service           = local.service
  name              = "s3"
  description       = "S3 Bucket"
  enable_versioning = false
}

# Cognito User Pool
module "cognito" {
  source      = "../../Modules/Cognito"
  service     = local.service
  name        = "cognito-user-pool"
  description = "Cognito User Pool"

  lambda_config = {
    pre_sign_up_arn = ""
  }

  google_configurations = {
    client_id     = "your client_id"
    client_secret = "your client_secret"
  }

  microsoft_configuration = {
    client_id     = "your client_id"
    client_secret = "your client_secret"
    oidc_issuer   = "https://login.microsoftonline.com/b8410e4c-fbf3-4b8b-8e97-ecab19b58cb5/v2.0"
  }

  client_configuration = {
    callback_urls = ["http://localhost:3000/cb", "http://localhost:3001/home", "https://staging.dittoflow.com/cb"]
    logout_urls   = ["http://localhost:3000/login", "http://localhost:3001/home", "https://example.com/cb", "https://staging.dittoflow.com/login"]
  }
}
