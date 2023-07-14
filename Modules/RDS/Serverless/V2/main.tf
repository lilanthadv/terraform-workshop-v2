/*======================================================================
  AWS RDS Cluster, RDS Serverless V2 Cluster Instance and Subnet Group    
========================================================================*/

locals {
  current_date = formatdate("YYYY-MMM-DD-hh-mm", timestamp())
}

# Create KMS Key
resource "aws_kms_key" "rds_encryption_key" {
  count               = var.storage_encrypted ? 1 : 0
  description         = "${var.cluster_description}, KMS key for RDS encryption"
  enable_key_rotation = true

  tags = merge(
    {
      Name        = "${var.cluster_name}-kms-key"
      Description = "${var.cluster_description}, KMS key for RDS encryption"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create Database Cluster
resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier = var.cluster_name

  engine               = var.engine
  engine_version       = var.engine_version
  engine_mode          = var.engine_mode
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = var.master_password
  port                 = var.port
  deletion_protection  = var.deletion_protection
  enable_http_endpoint = var.enable_http_endpoint

  # Encryption Configuration
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted ? aws_kms_key.rds_encryption_key[0].arn : null

  # Scaling Configuration
  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  # Snapshot Configuration
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.cluster_name}-snapshot-${local.current_date}"

  vpc_security_group_ids = var.security_groups
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = merge(
    {
      Name        = var.cluster_name
      Description = var.cluster_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create Database Instance
resource "aws_rds_cluster_instance" "db_instance" {
  cluster_identifier = aws_rds_cluster.db_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db_cluster.engine
  engine_version     = aws_rds_cluster.db_cluster.engine_version

  tags = merge(
    {
      Name        = "${var.cluster_name}-instance"
      Description = "${var.cluster_description}, Instance"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create Database Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.cluster_name}-subnet-group"
  description = "${var.cluster_description}, Subnet Group"
  subnet_ids  = var.subnets

  tags = merge(
    {
      Name        = "${var.cluster_name}-subnet-group"
      Description = "${var.cluster_description}, Subnet Group"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
