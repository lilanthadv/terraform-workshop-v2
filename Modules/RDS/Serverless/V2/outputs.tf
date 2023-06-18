output "database_identifier" {
  value = aws_rds_cluster.db_cluster.id
}

output "database_endpoint" {
  value = aws_rds_cluster.db_cluster.endpoint
}

output "database_arn" {
  value = aws_rds_cluster.db_cluster.arn
}
