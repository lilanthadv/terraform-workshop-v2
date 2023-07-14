/*=======================================================
  AWS CodePipeline for build and deployment
========================================================*/

resource "aws_codepipeline" "aws_codepipeline" {
  name     = var.codepipeline_name
  role_arn = var.pipe_role

  artifact_store {
    location = var.artifact_store_s3_bucket
    type     = var.artifact_store_type
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.git_repository_name
        BranchName     = var.git_branch_name
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

  tags = merge(
    {
      Name        = var.codepipeline_name
      Description = var.codepipeline_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
