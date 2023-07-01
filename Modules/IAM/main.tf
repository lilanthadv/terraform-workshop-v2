/*===========================================
  AWS IAM for different resources
============================================*/

### ECS Task Excecution Role and Policies
# ECS Task Excecution Role
resource "aws_iam_role" "ecs_task_excecution_role" {
  count              = var.create_ecs_role == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
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

# Task Excecution Role Policies Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_excecution_role_policy_attachment" {
  count      = length(aws_iam_role.ecs_task_excecution_role) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_excecution_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}

### ECS Task Role and Policies
# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  count              = var.create_ecs_role == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name_ecs_task_role}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name_ecs_task_role}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# ECS Task Role Policy
resource "aws_iam_policy" "policy_for_ecs_task_role" {
  count       = var.create_ecs_role == true ? 1 : 0
  name        = "${var.service.resource_name_prefix}-${var.name_ecs_task_role}-policy"
  description = var.description
  policy      = data.aws_iam_policy_document.role_policy_ecs_task_role.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name_ecs_task_role}-policy"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# ECS Task Role Policies Attachments
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  count      = var.create_ecs_role == true ? 1 : 0
  policy_arn = aws_iam_policy.policy_for_ecs_task_role[0].arn
  role       = aws_iam_role.ecs_task_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}

### Codepipeline Role and Policies
# Codepipeline Role
resource "aws_iam_role" "codepipeline_role" {
  count              = var.create_codepipeline_role == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
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

# Codepipeline Role Policies
resource "aws_iam_policy" "codepipeline_role_policy" {
  count       = var.create_codepipeline_policy == true ? 1 : 0
  name        = "${var.service.resource_name_prefix}-${var.name}-policy"
  description = var.description
  policy      = data.aws_iam_policy_document.role_policy_codepipeline_role.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-policy"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Codepipeline Role Policies Attachment
resource "aws_iam_role_policy_attachment" "codedeploy_role_policy_attachment2" {
  count      = var.create_codepipeline_policy == true ? 1 : 0
  policy_arn = aws_iam_policy.codepipeline_role_policy[0].arn
  role       = var.attach_to

  lifecycle {
    create_before_destroy = true
  }
}


### Codebuild Role and Policies
# Codebuild Role
resource "aws_iam_role" "codebuild_role" {
  count              = var.create_codebuild_role == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
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

# Codebuild Role Policies
resource "aws_iam_policy" "codebuild_role_policy" {
  count       = var.create_codebuild_policy == true ? 1 : 0
  name        = "${var.service.resource_name_prefix}-${var.name}-policy"
  description = var.description
  policy      = data.aws_iam_policy_document.role_policy_codebuild_role.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-policy"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Codebuild Role Policies Attachment
resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  count      = var.create_codebuild_policy == true ? 1 : 0
  policy_arn = aws_iam_policy.codebuild_role_policy[0].arn
  role       = var.attach_to

  lifecycle {
    create_before_destroy = true
  }
}

### Codedeploy Role and Policies
# Codedeploy Role
resource "aws_iam_role" "codedeploy_role" {
  count              = var.create_codedeploy_role == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

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

# Codedeploy Role Policies Attachment
resource "aws_iam_role_policy_attachment" "codedeploy_role_policy_attachment" {
  count      = var.create_codedeploy_role == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codedeploy_role[0].name
}


