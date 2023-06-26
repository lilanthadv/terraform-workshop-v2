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

  # Canonical
  owners = ["099720109477"]
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
  key_pair_name               = "bastionhost"
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
  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = 80
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      protocol        = "tcp"
      ingress_port    = 443
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# Creating Application ALB
module "alb" {
  source              = "../../Modules/ALB"
  service             = local.service
  name                = "alb"
  description         = "Application ALB"
  create_alb          = true
  enable_https        = true
  subnets             = module.networking.public_subnets
  security_group      = module.security_group_alb.id
  target_group        = module.target_group.arn_tg
  ssl_certificate_arn = "arn:aws:acm:ap-southeast-2:642801335081:certificate/266992e2-0f7a-4066-b15f-dae1649522ec"
}

# ECS Role
module "ecs_role" {
  source             = "../../Modules/IAM"
  service            = local.service
  name               = "ecs-task-excecution-role"
  name_ecs_task_role = "ecs-task-role"
  description        = "ECS Role"
  create_ecs_role    = true
  database           = [module.database.database_arn]
}

# Creating a IAM Policy for Role
module "ecs_role_policy" {
  source        = "../../Modules/IAM"
  service       = local.service
  name          = "ecs-rp"
  description   = "IAM Policy for role"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# Creating ECR Repository to Store Docker Images
module "ecr" {
  source      = "../../Modules/ECR"
  service     = local.service
  name        = "repo"
  description = "ECR Repository to store Docker Images"
}

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
  docker_repo        = module.ecr.ecr_repository_url
  region             = var.region
  container_port     = var.container_port
  host_port          = var.host_port

  environment_variables = [
    {
      "name" : "ACCESS_KEY",
      "value" : var.access_key
    },
    {
      "name" : "COGNITO_ACCESS_KEY",
      "value" : var.access_key
    },
    {
      "name" : "COGNITO_CLIENT_ID",
      "value" : module.cognito.client_id
    },
    {
      "name" : "COGNITO_DOMAIN",
      "value" : "https://${module.cognito.domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
    },
    {
      "name" : "COGNITO_REDIRECT_URI",
      "value" : "https://dittoflow.com/cb"
    },
    {
      "name" : "COGNITO_REGION",
      "value" : var.region
    },
    {
      "name" : "COGNITO_SECRET_KEY",
      "value" : var.secret_key
    },
    {
      "name" : "COGNITO_USER_POOL_ID",
      "value" : module.cognito.id
    },
    {
      "name" : "DATABASE_URL",
      "value" : "postgresql://${var.master_username}:${var.master_password}@${module.database.proxy_endpoint}:5432/dittolocal?schema=ditto"
    },
    {
      "name" : "FRONT_END_URL",
      "value" : "https://dittoflow.com"
    },
    {
      "name" : "JWT_ISS",
      "value" : "https://${module.cognito.endpoint}"
    },
    {
      "name" : "PORT",
      "value" : var.host_port
    },
    {
      "name" : "SECRET_KEY",
      "value" : var.secret_key
    },
    {
      "name" : "SES_EMAIL",
      "value" : "no-reply@dittosoftware.com"
    },
    {
      "name" : "SQS_QUEUE_URL",
      "value" : module.sqs.queue_url
    },
  ]
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

# S3 Bucket for Frontend Application
module "s3_web" {
  source            = "../../Modules/S3"
  service           = local.service
  name              = "web-s3"
  description       = "S3 Bucket for front-end app"
  acl               = "public-read"
  enable_versioning = false
  enable_cloudfront = true
}

# Cognito User Pool
module "cognito" {
  source      = "../../Modules/Cognito"
  service     = local.service
  name        = "cognito-user-pool"
  description = "Cognito User Pool"

  lambda_config = {
    pre_sign_up_arn    = "arn:aws:lambda:ap-southeast-2:642801335081:function:autoConfirm_ditto_workflow_dev"
    custom_message_arn = "arn:aws:lambda:ap-southeast-2:642801335081:function:work_flow_reset_password_staging"
  }

  google_configurations = {
    client_id     = "198930728399-cp287otkh21l80hdjs7bsqe6h2bv7i3b.apps.googleusercontent.com"
    client_secret = "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"
  }

  microsoft_configuration = {
    client_id                 = "4b2a6342-3204-40ea-a9b8-f6deda3fa854"
    client_secret             = "f1U8Q~R~w-eje.QAq1~gx1At9ubOGbHLKzjGKbo2"
    oidc_issuer               = "https://login.microsoftonline.com/b8410e4c-fbf3-4b8b-8e97-ecab19b58cb5/v2.0"
    authorize_scopes          = "profile email openid"
    attributes_request_method = "GET"
  }

  client_configuration = {
    callback_urls = ["https://dittoflow.com/home", "https://dittoflow.com/cb"]
    logout_urls   = ["https://dittoflow.com/login", "https://dittoflow.com/home"]
  }

  schema_attributes = [
    {
      "name" : "email",
      "attribute_data_type" : "String",
      "developer_only_attribute" : false,
      "mutable" : true,
      "required" : true,
      "string_attribute_constraints" : {
        "min_length" : 1,
        "max_length" : 256
      }
    },
    {
      "name" : "firstName",
      "attribute_data_type" : "String",
      "developer_only_attribute" : false,
      "mutable" : true,
      "required" : false,
      "string_attribute_constraints" : {
        "min_length" : 1,
        "max_length" : 256
      }
    },
    {
      "name" : "lastName",
      "attribute_data_type" : "String",
      "developer_only_attribute" : false,
      "mutable" : true,
      "required" : false,
      "string_attribute_constraints" : {
        "min_length" : 1,
        "max_length" : 256
      }
    },
  ]

}

# S3 for CodePipeline
module "pipeline_artifact_store_s3" {
  source        = "../../Modules/S3"
  service       = local.service
  name          = "pipeline-artifact"
  description   = "S3 Bucket for CodePipeline Artifact Store"
  force_destroy = true
}

# Codebuild Role
module "codebuild_role" {
  source                = "../../Modules/IAM"
  service               = local.service
  name                  = "codebuild-role"
  description           = "Codebuild Role"
  create_codebuild_role = true
}

# Codebuild Role Policy
module "codebuild_role_policy" {
  source                  = "../../Modules/IAM"
  service                 = local.service
  name                    = "codebuild-role-policy"
  description             = "Codebuild Role Policy"
  create_policy           = true
  attach_to               = module.codebuild_role.name_role
  create_codebuild_policy = true
  ecr_repositories        = [module.ecr.ecr_repository_arn]
  code_build_projects     = [module.codebuild.project_arn]
}

# Creating CodeBuild project
module "codebuild" {
  source          = "../../Modules/CodeBuild"
  service         = local.service
  name            = "codebuild-project"
  description     = "CodeBuild project"
  codedeploy_role = module.codebuild_role.arn_role

  git_source = {
    git_source_type    = var.git_source_type
    git_repository_url = var.git_repository_url
  }

  environment_variables = [
    {
      "name" : "REPOSITORY_URI",
      "value" : module.ecr.ecr_repository_url
    },
    {
      "name" : "ECS_REGION",
      "value" : var.region
    },
    {
      "name" : "ECS_TASK_DEFINITION_NAME",
      "value" : module.ecs_taks_definition.task_definition_id
    },
    {
      "name" : "ECS_TASK_MEMORY",
      "value" : module.ecs_taks_definition.task_definition_memory
    },
    {
      "name" : "ECS_TASK_ROLE",
      "value" : module.ecs_role.arn_role_ecs_task_role
    },
    {
      "name" : "ECS_EXE_ROLE",
      "value" : module.ecs_role.arn_role
    },
    {
      "name" : "ECS_CLUSTER_NAME",
      "value" : module.ecs_cluster.ecs_cluster_name
    },
    {
      "name" : "ECS_SERVICE_NAME",
      "value" : module.ecs_service.ecs_service_name
    },
  ]

}

# Creating CodePipeline
module "codepipeline" {
  source                   = "../../Modules/CodePipeline"
  service                  = local.service
  name                     = "codepipeline"
  description              = "Codepipeline"
  pipe_role                = module.codebuild_role.arn_role
  artifact_store_s3_bucket = module.pipeline_artifact_store_s3.id
  codebuild_project        = module.codebuild.project_id

  git_connection_arn = var.git_connection_arn
  git_repository_id  = var.git_repository_id
  git_branch_name    = var.git_branch_name
}
