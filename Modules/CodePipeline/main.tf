/*=======================================================
  AWS CodePipeline for build and deployment
========================================================*/

resource "aws_codepipeline" "aws_codepipeline" {
  name     = "${var.service.resource_name_prefix}-${var.name}"
  role_arn = var.pipe_role

  artifact_store {
    location = var.artifact_store_s3_bucket
    type     = var.artifact_store_type
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = var.git_connection_arn
        FullRepositoryId = var.git_repository_id
        BranchName       = var.git_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = var.codebuild_project
      }
    }
  }

  lifecycle {
    ignore_changes = [stage[0].action[0].configuration]
  }

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
