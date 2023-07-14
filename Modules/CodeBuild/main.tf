/*==================================
  AWS CodeBuild Project
===================================*/

resource "aws_codebuild_project" "codebuild" {
  name        = var.codebuild_app_name
  description = var.codebuild_app_description

  build_timeout = var.build_timeout
  service_role  = var.codedeploy_role

  artifacts {
    type = var.artifacts.type
  }

  environment {
    compute_type    = var.environment_compute_type
    image           = var.environment_image
    type            = var.environment_type
    privileged_mode = var.environment_privileged_mode

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

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? [1] : []
    content {
      vpc_id             = var.vpc
      subnets            = var.subnets
      security_group_ids = var.security_group_ids
    }
  }

  tags = merge(
    {
      Name        = var.codebuild_app_name
      Description = var.codebuild_app_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
