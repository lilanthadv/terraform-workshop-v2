/*===============================================================
  Terraform Module for AWS S3 Bucket And Related Configurations  
=================================================================*/

# Create S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  force_destroy = var.enable_force_destroy

  tags = merge(
    {
      Name        = var.bucket_name
      Description = var.bucket_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Create S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  count = var.acl == "public-read" ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

# Create S3 Bucket ACL
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id

  acl = var.acl

  depends_on = [
    aws_s3_bucket_ownership_controls.s3_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.s3_bucket_public_access_block[0]
  ]
}
