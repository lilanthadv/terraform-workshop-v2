/*======================================================================
  AWS S3 Bucket   
========================================================================*/

locals {
  bucket_name = "${var.service.resource_name_prefix}-${var.name}"
}

# S3 Bucket
resource "aws_s3_bucket" "s3" {
  bucket = local.bucket_name

  force_destroy = var.force_destroy

  tags = {
    Name        = "${local.bucket_name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "s3_cors_configuration" {
  count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_public_access_block" "s3_acl_public_access_block" {
  count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_acl_ownership" {
  # count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket_public_access_block.s3_acl_public_access_block]
}

resource "aws_s3_bucket_acl" "s3_cors_configuration_acl" {
  # count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  acl    = var.acl

  depends_on = [aws_s3_bucket_ownership_controls.s3_acl_ownership]
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PolicyForCloudFrontPrivateContent"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity[0].id}"
        }
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.s3_acl_public_access_block]
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.enable_cloudfront ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.s3.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity[0].cloudfront_access_identity_path
    }
  }

  aliases = var.cloudfront_alternate_domain_names

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = aws_s3_bucket.s3.id

    cache_policy_id = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    minimum_protocol_version = var.cloudfront_minimum_protocol_version
    ssl_support_method       = var.cloudfront_ssl_support_method
  }

  tags = {
    Name        = "${local.bucket_name}-cloudfront"
    Description = "${var.description} CloudFront Distribution"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count   = var.enable_cloudfront ? 1 : 0
  comment = aws_s3_bucket.s3.bucket_regional_domain_name
}
