output "id" {
  value = aws_s3_bucket.s3_web.id
}

output "arn" {
  value = aws_s3_bucket.s3_web.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.s3_web.bucket_domain_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_web_distribution.domain_name
}

