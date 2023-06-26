/*======================================================================
  AWS RDS Cluster, RDS Serverless V2 Cluster Instance and Subnet Group    
========================================================================*/

locals {
  current_date = formatdate("YYYY-MMM-DD-hh-mm", timestamp())
}

resource "aws_kms_key" "rds_encryption_key" {
  count               = var.storage_encrypted ? 1 : 0
  description         = "KMS key for RDS encryption"
  enable_key_rotation = true

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-kms-key"
    Description = "KMS key for RDS encryption"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Create database cluster
resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier   = "${var.service.resource_name_prefix}-${var.name}-cluster"
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
  final_snapshot_identifier = "${var.service.resource_name_prefix}-${var.name}-snapshot-${local.current_date}"

  vpc_security_group_ids = var.security_groups
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-cluster"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Create database instance
resource "aws_rds_cluster_instance" "db_instance" {
  cluster_identifier = aws_rds_cluster.db_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db_cluster.engine
  engine_version     = aws_rds_cluster.db_cluster.engine_version

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-instance"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Create database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.service.resource_name_prefix}-${var.name}-subnet-group"
  description = "${var.description} subnet group"
  subnet_ids  = var.subnets

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-subnet-group"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}
