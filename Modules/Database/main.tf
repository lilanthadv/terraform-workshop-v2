# Create database cluster
resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier   = "${var.app_name}-${var.name}"
  engine               = var.engine
  engine_version       = var.engine_version
  engine_mode          = var.engine_mode
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = var.master_password
  port                 = var.port
  deletion_protection  = var.deletion_protection
  enable_http_endpoint = var.enable_http_endpoint

  # Scaling Configuration
  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  # Snapshot Configuration
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.app_name}-${var.name}-final-snapshot"

  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create database instance"
resource "aws_rds_cluster_instance" "db_instance" {
  cluster_identifier = aws_rds_cluster.db_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db_cluster.engine
  engine_version     = aws_rds_cluster.db_cluster.engine_version

  tags = {
    Name        = "${var.app_name}-db-instance"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.app_name}-db-subnet-group"
  description = "DB subnet group for the Aurora serverless DB cluster"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.app_name}-db-subnet-group"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create database security group
resource "aws_security_group" "db_security_group" {
  name        = "${var.app_name}-db-security-group"
  description = "Security group for DB instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-db-security-group"
    Environment = var.environment
    Version     = var.app_version
  }
}

