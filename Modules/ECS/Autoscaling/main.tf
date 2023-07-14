/*====================================
  AWS ECS Autoscaling
=====================================*/

# AWS Autoscaling Target To Linke The ECS Cluster And Service
resource "aws_appautoscaling_target" "ecs_target" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = var.appautoscaling_target_scalable_dimension
  service_namespace  = var.appautoscaling_target_service_namespace

  lifecycle {
    ignore_changes = [
      role_arn,
    ]
  }

  tags = merge(
    {
      Name        = var.autoscaling_name
      Description = var.autoscaling_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# AWS Autoscaling Policy Using CPU Allocation
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.autoscaling_name}-policy-cpu"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# AWS Autoscaling Policy Using Memory Allocation
resource "aws_appautoscaling_policy" "memory" {
  name               = "${var.autoscaling_name}-policy-memory"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

/*==============================================
        AWS Cloudwatch for ECS Autoscaling
===============================================*/

# High Memory Alarm
resource "aws_cloudwatch_metric_alarm" "high-memory-policy-alarm" {
  alarm_name        = "${var.autoscaling_name}-cloudwatch-high-memory-alarm"
  alarm_description = "High Memory Alarm for ecs service-${var.service_name}"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 50

  dimensions = {
    "ServiceName" = var.service_name,
    "ClusterName" = var.cluster_name
  }

  tags = merge(
    {
      Name        = "${var.autoscaling_name}-cloudwatch-high-memory-alarm"
      Description = "High Memory Alarm for ecs service-${var.service_name}"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high-cpu-policy-alarm" {
  alarm_name        = "${var.autoscaling_name}-cloudwatch-high-cpu-alarm"
  alarm_description = "High CPUPolicy alarm for ecs service-${var.service_name}"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 50

  dimensions = {
    "ServiceName" = var.service_name,
    "ClusterName" = var.cluster_name
  }

  tags = merge(
    {
      Name        = "${var.autoscaling_name}-cloudwatch-high-cpu-alarm"
      Description = "High CPUPolicy alarm for ecs service-${var.service_name}"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
