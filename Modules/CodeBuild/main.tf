/*==================================
  AWS CodeBuild Project
===================================*/

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.service.resource_name_prefix}-${var.name}"
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = var.codedeploy_role

  artifacts {
    type = var.artifacts.type
  }

  environment {
    compute_type    = var.environment.compute_type
    image           = var.environment.image
    type            = var.environment.type
    privileged_mode = var.environment.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_logs_group_name
      stream_name = var.cloudwatch_logs_stream_name
    }
  }

  source {
    type            = var.git_source.git_source_type
    location        = var.git_source.git_repository_url
    git_clone_depth = 1
  }

  source_version = "master"

  # vpc_config {
  #   vpc_id             = var.vpc
  #   subnets            = var.subnets
  #   security_group_ids = var.security_group_ids
  # }


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
