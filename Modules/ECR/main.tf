/*=========================================
  AWS Elastic Container Repository
==========================================*/

# AWS ECR Repository
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.ecr_name
  image_tag_mutability = var.ecr_repository_image_tag_mutability

  tags = merge(
    {
      Name        = var.ecr_name
      Description = var.ecr_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
