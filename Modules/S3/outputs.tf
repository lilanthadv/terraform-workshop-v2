output "id" {
  value = aws_s3_bucket.s3.id
}

output "arn" {
  value = aws_s3_bucket.s3.arn
}

output "bucket_name" {
  value = aws_s3_bucket.s3.bucket
}

output "bucket_domain_name" {
  value = aws_s3_bucket.s3.bucket_domain_name
}

output "cloudfront_domain_name" {
  value = var.enable_cloudfront ? aws_cloudfront_distribution.s3_distribution[0].domain_name : ""
}

output "cloudfront_distribution_id" {
  value = var.enable_cloudfront ? aws_cloudfront_distribution.s3_distribution[0].id : ""
}

