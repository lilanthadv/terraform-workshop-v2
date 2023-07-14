/*===========================================
  AWS IAM for different resources
============================================*/

# Create ECS Task Excecution Role
resource "aws_iam_role" "ecs_task_excecution_role" {
  count              = var.create_ecs_role == true ? 1 : 0
  name               = var.role_name
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

  tags = merge(
    {
      Name        = var.role_name
      Description = var.role_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  count              = var.create_ecs_role == true ? 1 : 0
  name               = var.ecs_task_role_name
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

  tags = merge(
    {
      Name        = var.ecs_task_role_name
      Description = var.ecs_task_role_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Devops Role
resource "aws_iam_role" "devops_role" {
  count              = var.create_codebuild_role == true ? 1 : 0
  name               = var.role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com",
          "codedeploy.amazonaws.com",
          "codepipeline.amazonaws.com",
          "codecommit.amazonaws.com"
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

  tags = merge(
    {
      Name        = var.role_name
      Description = var.role_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Codedeploy Role
resource "aws_iam_role" "codedeploy_role" {
  count              = var.create_codedeploy_role == true ? 1 : 0
  name               = var.role_name
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

  tags = merge(
    {
      Name        = var.role_name
      Description = var.role_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# IAM Policies
resource "aws_iam_policy" "policy_for_role" {
  count       = var.create_codebuild_policy == true ? 1 : 0
  name        = "${var.role_name}-policy"
  description = "${var.role_description}, Policy"
  policy      = data.aws_iam_policy_document.role_policy_devops_role.json

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name        = "${var.role_name}-policy"
      Description = "${var.role_description}, Policy"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Policy for ECS Task Role
resource "aws_iam_policy" "policy_for_ecs_task_role" {
  count       = var.create_ecs_role == true ? 1 : 0
  name        = "${var.ecs_task_role_name}-policy"
  description = "${var.ecs_task_role_description}, Policy"
  policy      = data.aws_iam_policy_document.role_policy_ecs_task_role.json

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name        = "${var.ecs_task_role_name}-policy"
      Description = "${var.ecs_task_role_description}, Policy"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# IAM Policies Attachments
resource "aws_iam_role_policy_attachment" "ecs_attachment" {
  count      = var.create_ecs_role == true ? 1 : 0
  policy_arn = aws_iam_policy.policy_for_ecs_task_role[0].arn
  role       = aws_iam_role.ecs_task_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = length(aws_iam_role.ecs_task_excecution_role) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_excecution_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachment2" {
  count      = var.create_codebuild_policy == true ? 1 : 0
  policy_arn = aws_iam_policy.policy_for_role[0].arn
  role       = var.attach_to

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_attachment" {
  count      = var.create_codedeploy_role == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codedeploy_role[0].name
}
