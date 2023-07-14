/*======================================================================
  AWS RDS Proxy    
========================================================================*/

# Create IAM Role
resource "aws_iam_role" "db_proxy_iam_role" {
  name = "${var.cluster_name}-proxy-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    {
      Name        = "${var.cluster_name}-proxy-iam-role"
      Description = "${var.cluster_description}, Proxy IAM Role"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create IAM Policy
resource "aws_iam_policy" "db_proxy_iam_role_policy" {
  name = "${var.cluster_name}-proxy-iam-role-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = merge(
    {
      Name        = "${var.cluster_name}-proxy-iam-role-policy"
      Description = "${var.cluster_description}, Proxy IAM Role Policy"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "db_proxy_iam_role_policy_attachment" {
  role       = aws_iam_role.db_proxy_iam_role.name
  policy_arn = aws_iam_policy.db_proxy_iam_role_policy.arn
}

resource "random_string" "random_key_suffix" {
  length  = 8
  special = false
}

# Create Secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.cluster_name}-proxy-secret-${random_string.random_key_suffix.result}"

  kms_key_id = var.storage_encrypted ? aws_kms_key.rds_encryption_key[0].arn : null

  tags = merge(
    {
      Name        = "${var.cluster_name}-proxy-secret-${random_string.random_key_suffix.result}"
      Description = "${var.cluster_description}, Proxy Secret"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create Secret Version
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = <<EOF
{
  "username": "${var.master_username}",
  "password": "${var.master_password}",
  "engine": "${var.engine}",
  "host": "${aws_rds_cluster.db_cluster.endpoint}",
  "port": "${var.port}",
  "dbname": "${var.database_name}",
  "dbInstanceIdentifier": "${aws_rds_cluster.db_cluster.id}"
}
EOF
}

# Create Database Proxy
resource "aws_db_proxy" "db_proxy" {
  name                   = "${var.cluster_name}-proxy"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  vpc_security_group_ids = var.security_groups
  vpc_subnet_ids         = var.subnets
  role_arn               = aws_iam_role.db_proxy_iam_role.arn

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_secret.arn
  }

  tags = merge(
    {
      Name        = "${var.cluster_name}-proxy"
      Description = "${var.cluster_description}, Proxy"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create Database Proxy Default Target Group
resource "aws_db_proxy_default_target_group" "db_proxy_target_group" {
  db_proxy_name = aws_db_proxy.db_proxy.name

  connection_pool_config {
    max_connections_percent = 100
  }
}

# Create Database Proxy Target
resource "aws_db_proxy_target" "db_proxy_target" {
  db_cluster_identifier = aws_rds_cluster.db_cluster.cluster_identifier
  db_proxy_name         = aws_db_proxy.db_proxy.name

  target_group_name = aws_db_proxy_default_target_group.db_proxy_target_group.name
}
