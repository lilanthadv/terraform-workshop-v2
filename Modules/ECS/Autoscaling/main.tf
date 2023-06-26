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

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = "Autoscaling target to linke the ECS cluster and service"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# AWS Autoscaling Policy Using CPU Allocation
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service.resource_name_prefix}-${var.name}-policy-cpu"
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
  name               = "${var.service.resource_name_prefix}-${var.name}-policy-memory"
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
  alarm_name          = "${var.service.resource_name_prefix}-${var.name}-cloudwatch-high-memory-alarm"
  alarm_description   = "High Memory for ecs service-${var.service_name}"
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

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-cloudwatch-high-memory-alarm"
    Description = "High memory alarm"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high-cpu-policy-alarm" {
  alarm_name          = "${var.service.resource_name_prefix}-${var.name}-cloudwatch-high-cpu-alarm"
  alarm_description   = "High CPUPolicy Landing Page for ecs service-${var.service_name}"
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

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-cloudwatch-high-cpu-alarm"
    Description = "High CPU alarm"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}
