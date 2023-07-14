# Provider
provider "aws" {
  region = var.region
}

# Local Variables
locals {
  app_name                   = "${var.app_name}-${var.environment}"
  availability_zones         = data.aws_availability_zones.az_availables.names
  username                   = split("/", data.aws_caller_identity.current.arn)[1]
  database_connection_string = "postgresql://${var.database_master_username}:${var.database_master_password}@${module.database.proxy_endpoint}:${var.database_port}/${var.database_name}"
}

# Networking
module "networking" {
  source = "../../Modules/Networking"

  vpc_name        = "${local.app_name}-vpc"
  vpc_description = "VPC for Application"

  availability_zones = local.availability_zones
}

# Security Group for Database
module "security_group_db" {
  source = "../../Modules/SecurityGroup"

  security_group_name        = "${local.app_name}-db-sg"
  security_group_description = "Security Group for Database"

  vpc = module.networking.vpc

  # ingress_rules = [
  #   {
  #     protocol        = "tcp"
  #     ingress_port    = var.database_port
  #     cidr_blocks     = ["0.0.0.0/0"]
  #     security_groups = []
  #   },
  #   {
  #     protocol        = "tcp"
  #     ingress_port    = var.database_port
  #     cidr_blocks     = ["0.0.0.0/0"]
  #     security_groups = [module.security_group_bastion_host.id]
  #   },
  #   {
  #     protocol        = "tcp"
  #     ingress_port    = var.database_port
  #     cidr_blocks     = ["0.0.0.0/0"]
  #     security_groups = [module.security_group_ecs_task.id]
  #   },
  #   {
  #     protocol        = "tcp"
  #     ingress_port    = var.database_port
  #     cidr_blocks     = ["0.0.0.0/0"]
  #     security_groups = [module.codebuild_security_group.id]
  #   }
  # ]
}

# Database
module "database" {
  source = "../../Modules/RDS/Serverless/V2"

  cluster_name        = "${local.app_name}-db"
  cluster_description = "Serverless V2 RDS Database"

  availability_zones   = local.availability_zones
  subnets              = module.networking.private_subnets
  security_groups      = [module.security_group_db.id]
  engine               = var.database_engine
  engine_version       = var.database_engine_version
  engine_mode          = var.database_engine_mode
  database_name        = var.database_name
  master_username      = var.database_master_username
  master_password      = var.database_master_password
  port                 = var.database_port
  deletion_protection  = var.database_deletion_protection
  skip_final_snapshot  = var.database_skip_final_snapshot
  enable_http_endpoint = var.database_enable_http_endpoint
  storage_encrypted    = var.database_storage_encrypted

  # Scaling Configuration
  min_capacity = var.database_scaling_min_capacity
  max_capacity = var.database_scaling_max_capacity
}

# Security Group for Bastion Host
module "security_group_bastion_host" {
  source = "../../Modules/SecurityGroup"

  security_group_name        = "${local.app_name}-bastion-host-sg"
  security_group_description = "Security Group for Bastion Host"

  vpc = module.networking.vpc

  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = 22
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      protocol        = "tcp"
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# Bastion Host for Database
module "bastion_host" {
  source = "../../Modules/EC2"

  instance_name        = "${local.app_name}-bastion-host"
  instance_description = "Bastion Host for Database"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_host_instance_type
  subnet_id                   = module.networking.public_subnets[0]
  security_groups             = [module.security_group_bastion_host.id]
  associate_public_ip_address = var.bastion_host_associate_public_ip_address
  availability_zone           = local.availability_zones[0]
  user_data                   = file("./bastion_host_user_data.sh")
  associate_elastic_ip        = var.bastion_host_associate_elastic_ip
  key_pair_name               = var.bastion_host_key_pair_name
}

# ECS Resources
# ECS Target Group for ALB
module "target_group" {
  source = "../../Modules/ALB"

  target_group_name        = "${local.app_name}-alb-tg"
  target_group_description = "Target Group for ALB"

  create_target_group = true
  port                = var.ecs_taks_definition_host_port
  protocol            = var.ecs_target_group_protocol
  vpc                 = module.networking.vpc
  tg_type             = var.ecs_target_group_tg_type
  health_check_path   = var.ecs_target_group_health_check_path
  health_check_port   = var.ecs_taks_definition_host_port
}

# ECS Security Group for ALB
module "security_group_alb" {
  source = "../../Modules/SecurityGroup"

  security_group_name        = "${local.app_name}-alb-sg"
  security_group_description = "Security Group for the ALB"

  vpc = module.networking.vpc

  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = 80
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# ECS ALB
module "alb" {
  source = "../../Modules/ALB"

  alb_name        = "${local.app_name}-alb"
  alb_description = "ECS ALB"

  create_alb          = true
  enable_https        = var.ecs_alb_enable_https
  subnets             = module.networking.public_subnets
  security_group      = module.security_group_alb.id
  target_group        = module.target_group.arn_tg
  ssl_certificate_arn = var.ecs_alb_ssl_certificate_arn
}

# ECS IAM Role
module "ecs_role" {
  source = "../../Modules/IAM"

  role_name        = "${local.app_name}-ecs-task-excecution-role"
  role_description = "ECS Task Excecution Role"

  ecs_task_role_name        = "${local.app_name}-ecs-task-role"
  ecs_task_role_description = "ECS Task Role"

  create_ecs_role = true
  database        = [module.database.database_arn]
}

# ECS IAM Policy for ECS Role
module "ecs_role_policy" {
  source = "../../Modules/IAM"

  role_name        = "${local.app_name}-ecs-rp"
  role_description = "ECS IAM Policy for ECS Role"

  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# ECR Repository to Store Docker Images
module "ecr" {
  source = "../../Modules/ECR"

  ecr_name        = "${local.app_name}-repo"
  ecr_description = "ECR Repository to store Docker Images"
}

# ECS Task Definition
module "ecs_taks_definition" {
  source = "../../Modules/ECS/TaskDefinition"

  taks_definition_name        = "${local.app_name}-td"
  taks_definition_description = "ECS Task Definition"

  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = var.ecs_taks_definition_cpu
  memory             = var.ecs_taks_definition_memory
  docker_repo        = module.ecr.ecr_repository_url
  region             = var.region
  container_port     = var.ecs_service_container_port
  host_port          = var.ecs_taks_definition_host_port

  environment_variables = [
    {
      "name" : "",
      "value" : ""
    }
  ]
}

# ECS Security Group for ECS Task
module "security_group_ecs_task" {
  source = "../../Modules/SecurityGroup"

  security_group_name        = "${local.app_name}-ecs-task-sg"
  security_group_description = "Security Group for ECS Task"

  vpc = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = var.ecs_taks_definition_host_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [module.security_group_alb.id]
  }]
}

# ECS Cluster 
module "ecs_cluster" {
  source = "../../Modules/ECS/Cluster"

  cluster_name        = "${local.app_name}-ecs-cluster"
  cluster_description = "ECS Cluster"
}

# ECS Service
module "ecs_service" {
  source = "../../Modules/ECS/Service"

  service_name        = "${local.app_name}-service"
  service_description = "ECS Service"

  desired_tasks       = var.ecs_service_desired_tasks
  arn_security_group  = module.security_group_ecs_task.id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group.arn_tg
  arn_task_definition = module.ecs_taks_definition.arn_task_definition
  subnets             = module.networking.private_subnets
  container_port      = var.ecs_service_container_port
  container_name      = module.ecs_taks_definition.container_name

  depends_on = [module.alb]
}

# ECS Autoscaling
module "ecs_autoscaling" {
  source = "../../Modules/ECS/Autoscaling"

  autoscaling_name        = "${local.app_name}-autoscaling"
  autoscaling_description = "ECS Autoscaling Policies"

  cluster_name = module.ecs_cluster.ecs_cluster_name
  service_name = module.ecs_service.ecs_service_name
  min_capacity = var.ecs_autoscaling_min_capacity
  max_capacity = var.ecs_autoscaling_max_capacity

  depends_on = [module.ecs_service]
}

# Cognito User Pool
module "cognito" {
  source = "../../Modules/Cognito"

  cognito_user_pool_name        = "${local.app_name}-cognito-user-pool"
  cognito_user_pool_description = "Cognito User Pool"

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
  ]
}

# S3 Bucket for CodePipeline
module "pipeline_artifact_store_s3" {
  source = "../../Modules/S3"

  bucket_name        = "${local.app_name}-code-pipeline-artifact-store"
  bucket_description = "S3 bucket for code pipeline artifact store"

  acl                  = "private"
  enable_force_destroy = true
}

# Codebuild Role
module "codebuild_role" {
  source = "../../Modules/IAM"

  role_name        = "${local.app_name}-codebuild-role"
  role_description = "Codebuild Role"

  create_codebuild_role = true
}

# Codebuild Role Policy
module "codebuild_role_policy" {
  source = "../../Modules/IAM"

  role_name        = "${local.app_name}-codebuild-role-policy"
  role_description = "Codebuild Role Policy"

  create_policy            = true
  attach_to                = module.codebuild_role.name_role
  create_codebuild_policy  = true
  ecr_repositories         = [module.ecr.ecr_repository_arn]
  code_build_projects      = ["*"]
  code_commit_repositories = ["arn:aws:codecommit:ap-southeast-2:048102882581:code-commit-repo-test-app"]

  depends_on = [module.ecr, module.codebuild_role]
}

# Security Group for Codebuild Server
module "codebuild_security_group" {
  source = "../../Modules/SecurityGroup"

  security_group_name        = "${local.app_name}-codebuild-sg-server"
  security_group_description = "Security Group for Codebuild Server"

  vpc           = module.networking.vpc
  ingress_rules = []
}

# CodeBuild Project for Server App
module "codebuild" {
  source = "../../Modules/CodeBuild"

  codebuild_app_name        = "${local.app_name}-codebuild-project"
  codebuild_app_description = "CodeBuild"

  codedeploy_role = module.codebuild_role.arn_role

  git_source = {
    git_source_type    = var.git_source_type
    git_repository_url = var.git_repository_url
  }

  enable_vpc         = true
  vpc                = module.networking.vpc
  subnets            = module.networking.private_subnets
  security_group_ids = [module.codebuild_security_group.id]

  environment_variables = [
    {
      "name" : "AWS_DEFAULT_REGION",
      "value" : var.region
    }
  ]

  depends_on = [module.networking, module.codebuild_security_group, module.codebuild_role, module.codebuild_role_policy]
}

# CodePipeline for Server App
module "codepipeline" {
  source = "../../Modules/CodePipeline"

  codepipeline_name        = "${local.app_name}-codepipeline"
  codepipeline_description = "Codepipeline"

  pipe_role                = module.codebuild_role.arn_role
  artifact_store_s3_bucket = module.pipeline_artifact_store_s3.id
  codebuild_project        = module.codebuild.project_id

  git_repository_name = var.git_repository_name
  git_branch_name     = var.git_repository_branch

  depends_on = [module.pipeline_artifact_store_s3, module.codebuild, module.codebuild_role, module.codebuild_role_policy]
}

