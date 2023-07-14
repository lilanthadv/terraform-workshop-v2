/*=============================
        AWS ECS Cluster
===============================*/

# AWS ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

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
