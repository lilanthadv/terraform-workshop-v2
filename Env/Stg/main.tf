# Provider
provider "aws" {
  region = var.region
}

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
  database_connection_string = "postgresql://${var.database_master_username}:${var.database_master_password}@${module.database.proxy_endpoint}:${var.database_port}/${var.database_name}?schema=${var.database_schema}"
}

# Networking
module "networking" {
  source             = "../../Modules/Networking"
  service            = local.service
  name               = "vpc"
  description        = "VPC for Application"
  availability_zones = local.availability_zones
}

# Security Group for Database
module "security_group_db" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "db-sg"
  description = "Security Group for Database"
  vpc         = module.networking.vpc
  ingress_rules = [
    {
      protocol        = "tcp"
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      protocol        = "tcp"
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [module.security_group_bastion_host.id]
    },
    {
      protocol        = "tcp"
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [module.security_group_ecs_task.id]
    },
    {
      protocol        = "tcp"
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [module.security_group_codebuild_server.id]
    }
  ]
}

# Database
module "database" {
  source               = "../../Modules/RDS/Serverless/V2"
  service              = local.service
  name                 = "db"
  description          = "Serverless V2 RDS Database"
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
      ingress_port    = var.database_port
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# Bastion Host for Database
module "bastion_host" {
  source                      = "../../Modules/EC2"
  service                     = local.service
  name                        = "bastion-host"
  description                 = "Bastion Host for Database"
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

# SQS
module "sqs" {
  source                      = "../../Modules/SQS"
  service                     = local.service
  name                        = "queue.fifo"
  description                 = "SQS service"
  fifo_queue                  = var.sqs_fifo_queue
  deduplication_scope         = var.sqs_deduplication_scope
  fifo_throughput_limit       = var.sqs_fifo_throughput_limit
  visibility_timeout_seconds  = var.sqs_visibility_timeout_seconds
  delay_seconds               = var.sqs_delay_seconds
  max_message_size            = var.sqs_max_message_size
  message_retention_seconds   = var.sqs_message_retention_seconds
  receive_wait_time_seconds   = var.sqs_receive_wait_time_seconds
  content_based_deduplication = var.sqs_content_based_deduplication
}

# ECS Resources
# ECS Target Group for ALB
module "target_group" {
  source              = "../../Modules/ALB"
  service             = local.service
  name                = "alb-tg"
  description         = "Target Group for ALB"
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

# ECS ALB
module "alb" {
  source              = "../../Modules/ALB"
  service             = local.service
  name                = "alb"
  description         = "ECS ALB"
  create_alb          = true
  enable_https        = var.ecs_alb_enable_https
  subnets             = module.networking.public_subnets
  security_group      = module.security_group_alb.id
  target_group        = module.target_group.arn_tg
  ssl_certificate_arn = var.ecs_alb_ssl_certificate_arn
}

# ECS IAM Role
module "ecs_role" {
  source             = "../../Modules/IAM"
  service            = local.service
  name               = "ecs-task-excecution-role"
  name_ecs_task_role = "ecs-task-role"
  description        = "ECS IAM Role"
  create_ecs_role    = true
  database           = [module.database.database_arn]
}

# ECS IAM Policy for ECS Role
module "ecs_role_policy" {
  source        = "../../Modules/IAM"
  service       = local.service
  name          = "ecs-rp"
  description   = "ECS IAM Policy for ECS Role"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# ECR Repository to Store Docker Images
module "ecr" {
  source      = "../../Modules/ECR"
  service     = local.service
  name        = "repo"
  description = "ECR Repository to store Docker Images"
}

# ECS Task Definition
module "ecs_taks_definition" {
  source             = "../../Modules/ECS/TaskDefinition"
  service            = local.service
  name               = "td"
  description        = "ECS Task Definition"
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
      "name" : "ACCESS_KEY",
      "value" : var.ecs_taks_definition_access_key
    },
    {
      "name" : "COGNITO_ACCESS_KEY",
      "value" : var.ecs_taks_definition_secret_key
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
      "value" : var.ecs_taks_definition_env_cognito_redirect_uri
    },
    {
      "name" : "COGNITO_REGION",
      "value" : var.region
    },
    {
      "name" : "COGNITO_SECRET_KEY",
      "value" : var.ecs_taks_definition_secret_key
    },
    {
      "name" : "COGNITO_USER_POOL_ID",
      "value" : module.cognito.id
    },
    {
      "name" : "DATABASE_URL",
      "value" : local.database_connection_string
    },
    {
      "name" : "FRONT_END_URL",
      "value" : var.ecs_taks_definition_env_front_end_url
    },
    {
      "name" : "JWT_ISS",
      "value" : "https://${module.cognito.endpoint}"
    },
    {
      "name" : "PORT",
      "value" : var.ecs_taks_definition_host_port
    },
    {
      "name" : "SECRET_KEY",
      "value" : var.ecs_taks_definition_secret_key
    },
    {
      "name" : "SES_EMAIL",
      "value" : var.ecs_taks_definition_env_ses_email
    },
    {
      "name" : "SQS_QUEUE_URL",
      "value" : module.sqs.queue_url
    },
    {
      "name" : "STRIPE_STANDERD_PLAN_PRICE_ID",
      "value" : var.ecs_taks_definition_env_stripe_standerd_plan_price_id
    },
    {
      "name" : "AWS_S3_BUCKET",
      "value" : var.ecs_taks_definition_env_aws_s3_bucket
    }
  ]
}

# ECS Security Group for ECS Task
module "security_group_ecs_task" {
  source      = "../../Modules/SecurityGroup"
  service     = local.service
  name        = "ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc         = module.networking.vpc
  ingress_rules = [{
    protocol        = "tcp"
    ingress_port    = var.ecs_taks_definition_host_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [module.security_group_alb.id]
  }]
}

# ECS Cluster 
module "ecs_cluster" {
  source      = "../../Modules/ECS/Cluster"
  service     = local.service
  name        = "ecs-cluster"
  description = "ECS Cluster"
}

# ECS Service
module "ecs_service" {
  depends_on          = [module.alb]
  source              = "../../Modules/ECS/Service"
  service             = local.service
  name                = "service"
  description         = "ECS Service"
  desired_tasks       = var.ecs_service_desired_tasks
  arn_security_group  = module.security_group_ecs_task.id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group.arn_tg
  arn_task_definition = module.ecs_taks_definition.arn_task_definition
  subnets             = module.networking.private_subnets
  container_port      = var.ecs_service_container_port
  container_name      = module.ecs_taks_definition.container_name
}

# ECS Autoscaling
module "ecs_autoscaling" {
  depends_on   = [module.ecs_service]
  source       = "../../Modules/ECS/Autoscaling"
  service      = local.service
  name         = "autoscaling"
  description  = "ECS Autoscaling Policies"
  cluster_name = module.ecs_cluster.ecs_cluster_name
  service_name = module.ecs_service.ecs_service_name
  min_capacity = var.ecs_autoscaling_min_capacity
  max_capacity = var.ecs_autoscaling_max_capacity
}

# S3 Bucket for Client Application
module "s3_client_app_bucket" {
  source                            = "../../Modules/S3"
  service                           = local.service
  name                              = "web-s3"
  description                       = "S3 Bucket for front-end app"
  acl                               = "public-read"
  enable_versioning                 = false
  enable_cloudfront                 = true
  cloudfront_alternate_domain_names = var.cloudfront_alternate_domain_names
}

# Cognito User Pool
module "cognito" {
  source      = "../../Modules/Cognito"
  service     = local.service
  name        = "cognito-user-pool"
  description = "Cognito User Pool"

  lambda_config = {
    pre_sign_up_arn    = var.cognito_lambda_config_pre_sign_up_arn
    custom_message_arn = var.cognito_lambda_config_custom_message_arn
  }

  google_configurations = {
    client_id     = var.cognito_google_configurations_client_id
    client_secret = var.cognito_google_configurations_client_secret
  }

  microsoft_configuration = {
    client_id                 = var.cognito_microsoft_configuration_client_id
    client_secret             = var.cognito_microsoft_configuration_client_secret
    oidc_issuer               = var.cognito_microsoft_configuration_oidc_issuer
    authorize_scopes          = var.cognito_microsoft_configuration_authorize_scopes
    attributes_request_method = var.cognito_microsoft_configuration_attributes_request_method
  }

  client_configuration = {
    callback_urls = var.cognito_client_configuration_callback_urls
    logout_urls   = var.cognito_client_configuration_logout_urls
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

# S3 Bucket for CodePipeline
module "pipeline_artifact_store_s3" {
  source        = "../../Modules/S3"
  service       = local.service
  name          = "pipeline-artifact"
  description   = "S3 Bucket for CodePipeline Artifact Store"
  force_destroy = var.s3_bucket_pipeline_artifact_store_force_destroy
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
  code_build_projects     = ["*"]

  depends_on = [module.ecr, module.codebuild_role]
}

# Security Group for Codebuild Server
module "security_group_codebuild_server" {
  source        = "../../Modules/SecurityGroup"
  service       = local.service
  name          = "codebuild-sg-server"
  description   = "Security Group for Codebuild Server"
  vpc           = module.networking.vpc
  ingress_rules = []
}

# CodeBuild Project for Server App
module "codebuild_server_app" {
  source          = "../../Modules/CodeBuild"
  service         = local.service
  name            = "codebuild-project-server-app"
  description     = "CodeBuild Server App"
  codedeploy_role = module.codebuild_role.arn_role

  git_source = {
    git_source_type    = var.server_app_git_source_type
    git_repository_url = var.server_app_git_repository_url
  }

  enable_vpc         = true
  vpc                = module.networking.vpc
  subnets            = module.networking.private_subnets
  security_group_ids = [module.security_group_codebuild_server.id]

  environment_variables = [
    {
      "name" : "REPOSITORY_NAME",
      "value" : module.ecr.ecr_repository_name
    },
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
      "name" : "ECS_TASK_CPU",
      "value" : module.ecs_taks_definition.task_definition_cpu
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
    {
      "name" : "DATABASE_URL",
      "value" : local.database_connection_string
    },
  ]

  depends_on = [module.networking, module.security_group_codebuild_server, module.codebuild_role, module.codebuild_role_policy]
}

# CodePipeline for Server App
module "codepipeline_server_app" {
  source                   = "../../Modules/CodePipeline"
  service                  = local.service
  name                     = "codepipeline-server-app"
  description              = "Codepipeline Server App"
  pipe_role                = module.codebuild_role.arn_role
  artifact_store_s3_bucket = module.pipeline_artifact_store_s3.id
  codebuild_project        = module.codebuild_server_app.project_id

  git_connection_arn = var.server_app_git_connection_arn
  git_repository_id  = var.server_app_git_repository_id
  git_branch_name    = var.server_app_git_branch_name

  depends_on = [module.pipeline_artifact_store_s3, module.codebuild_server_app, module.codebuild_role, module.codebuild_role_policy]
}

# CodeBuild Project for Client APP
module "codebuild_client_app" {
  source          = "../../Modules/CodeBuild"
  service         = local.service
  name            = "codebuild-project-client-app"
  description     = "CodeBuild project Client App"
  codedeploy_role = module.codebuild_role.arn_role

  git_source = {
    git_source_type    = var.client_app_git_source_type
    git_repository_url = var.client_app_git_repository_url
  }

  environment_compute_type    = "BUILD_GENERAL1_LARGE"
  environment_image           = "aws/codebuild/standard:5.0"
  environment_type            = "LINUX_CONTAINER"
  environment_privileged_mode = true

  environment_variables = [
    {
      "name" : "S3_BUCKET",
      "value" : module.s3_client_app_bucket.bucket_name
    },
    {
      "name" : "DISTRIBUTION_ID",
      "value" : module.s3_client_app_bucket.cloudfront_distribution_id
    },
    {
      "name" : "REACT_APP_API_URL",
      "value" : var.codebuild_client_app_env_api_url
    },
    {
      "name" : "REACT_APP_FRONT_END_URI",
      "value" : var.codebuild_client_app_env_front_end_uri
    },
    {
      "name" : "REACT_APP_AWS_REGION",
      "value" : var.region
    },
    {
      "name" : "REACT_APP_AWS_USER_POOL_ID",
      "value" : module.cognito.id
    },
    {
      "name" : "REACT_APP_AWS_WEB_CLIENT_ID",
      "value" : module.cognito.client_id
    },
    {
      "name" : "REACT_APP_GOOGLE_LOGIN_CLIENT_ID",
      "value" : module.cognito.provider_google_id
    },
    {
      "name" : "REACT_APP_COGNITO_DOMAIN",
      "value" : "${module.cognito.domain}.auth.${var.region}.amazoncognito.com"
    },
    {
      "name" : "REACT_APP_STRIPE_KEY",
      "value" : var.codebuild_client_app_env_stripe_key
    },
    {
      "name" : "REACT_APP_PDF_SERVICE_URL",
      "value" : var.codebuild_client_app_env_pdf_service_url
    },
    {
      "name" : "REACT_APP_WORD_SERVICE_URL",
      "value" : var.codebuild_client_app_env_word_service_url
    },
    {
      "name" : "REACT_APP_SYNCFUSION_KEY",
      "value" : var.codebuild_client_app_env_syncfusion_key
    },
  ]

  depends_on = [module.codebuild_role, module.codebuild_role_policy]
}

# CodePipeline for Client APP
module "codepipeline_client_app" {
  source                   = "../../Modules/CodePipeline"
  service                  = local.service
  name                     = "codepipeline-client-app"
  description              = "Codepipeline Client App"
  pipe_role                = module.codebuild_role.arn_role
  artifact_store_s3_bucket = module.pipeline_artifact_store_s3.id
  codebuild_project        = module.codebuild_client_app.project_id

  git_connection_arn = var.client_app_git_connection_arn
  git_repository_id  = var.client_app_git_repository_id
  git_branch_name    = var.client_app_git_branch_name

  depends_on = [module.pipeline_artifact_store_s3, module.codebuild_client_app, module.codebuild_role, module.codebuild_role_policy]
}
