# Get Current User Details
data "aws_caller_identity" "current_user" {}

# IAM Policy Documents
data "aws_iam_policy_document" "role_policy_devops_role" {
  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCodeCommitActions"
    effect = "Allow"
    actions = [
      "codecommit:Get*",
      "codecommit:List*",
      "codecommit:GitPull",
      "codecommit:UploadArchive"
    ]
    resources = var.code_commit_repositories
  }
  statement {
    sid    = "AllowCodebuildActions"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
      "codebuild:StopBuild"
    ]
    resources = var.code_build_projects
  }
  statement {
    sid    = "AllowCodebuildList"
    effect = "Allow"
    actions = [
      "codebuild:ListBuilds"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCodeDeployConfigs"
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig",
      "codedeploy:CreateDeploymentConfig",
      "codedeploy:CreateDeploymentGroup",
      "codedeploy:GetDeploymentTarget",
      "codedeploy:StopDeployment",
      "codedeploy:ListApplications",
      "codedeploy:ListDeploymentConfigs",
      "codedeploy:ListDeploymentGroups",
      "codedeploy:ListDeployments"

    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:GetAuthorizationToken",
    ]
    resources = concat(var.ecr_repositories, ["arn:aws:ecr:ap-southeast-2:642801335081:repository/node-18-alpine"])
  }
  statement {
    sid    = "AllowECRAuthorization"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCECSServiceActions"
    effect = "Allow"
    actions = [
      "ecs:ListServices",
      "ecs:ListTasks",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTaskSets",
      "ecs:DeleteTaskSet",
      "ecs:DeregisterContainerInstance",
      "ecs:CreateTaskSet",
      "ecs:UpdateCapacityProvider",
      "ecs:PutClusterCapacityProviders",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:UpdateService",
      "ecs:UpdateCluster",
      "ecs:UpdateTaskSet"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowDescribeSecurityGroups"
    effect = "Allow"
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeNetworkInterfaces",
      "ec2:AssignPrivateIpAddresses"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowVpcActions"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateTags",
      "ec2:DescribeDhcpOptions"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCloudWatchActions"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowConnectionActions"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCreateInvalidationActions"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "role_policy_ecs_task_role" {
  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = var.s3_bucket_assets
  }
  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowRDSdbActions"
    effect = "Allow"
    actions = [
      "rds:*",
    ]
    resources = var.database
  }
}
