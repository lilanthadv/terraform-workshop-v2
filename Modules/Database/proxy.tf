# Create iam role
resource "aws_iam_role" "db_proxy_iam_role" {
  name = "${var.app_name}-db-proxy-iam-role"

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

  tags = {
    Name        = "${var.app_name}-db-proxy-iam-role"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create iam policy
resource "aws_iam_policy" "db_proxy_iam_role_policy" {
  name = "${var.app_name}-db-proxy-iam-role-policy"

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

  tags = {
    Name        = "${var.app_name}-db-proxy-iam-role-policy"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create iam role policy attachment
resource "aws_iam_role_policy_attachment" "db_proxy_iam_role_policy_attachment" {
  role       = aws_iam_role.db_proxy_iam_role.name
  policy_arn = aws_iam_policy.db_proxy_iam_role_policy.arn
}

# Create secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.app_name}-db-secret"

  tags = {
    Name        = "${var.app_name}-db-secret"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create secret version
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

# Create db proxy
resource "aws_db_proxy" "db_proxy" {
  name                   = "${var.app_name}-db-proxy"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  vpc_subnet_ids         = var.subnet_ids
  role_arn               = aws_iam_role.db_proxy_iam_role.arn

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_secret.arn
  }

  tags = {
    Name        = "${var.app_name}-db-proxy"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create db proxy default target group
resource "aws_db_proxy_default_target_group" "db_proxy_target_group" {
  db_proxy_name = aws_db_proxy.db_proxy.name

  connection_pool_config {
    max_connections_percent = 100
  }
}

# Create db proxy target
resource "aws_db_proxy_target" "db_proxy_target" {
  db_cluster_identifier = aws_rds_cluster.db_cluster.cluster_identifier
  db_proxy_name         = aws_db_proxy.db_proxy.name

  target_group_name = aws_db_proxy_default_target_group.db_proxy_target_group.name
}
