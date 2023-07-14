/*==============================================================
  AWS Application Load Balancer + Target groups
===============================================================*/

# Create ALB
resource "aws_alb" "alb" {
  count              = var.create_alb == true ? 1 : 0
  name               = var.alb_name
  subnets            = [var.subnets[0], var.subnets[1]]
  security_groups    = [var.security_group]
  load_balancer_type = var.load_balancer_type
  internal           = var.load_balancer_internal
  enable_http2       = var.load_balancer_enable_http2
  idle_timeout       = var.load_balancer_idle_timeout

   tags = merge(
    {
      Name        = var.alb_name
    Description = var.alb_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create ALB Listenet for HTTPS
resource "aws_alb_listener" "https_listener" {
  count             = var.create_alb == true ? (var.enable_https == true ? 1 : 0) : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = var.target_group
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# Create ALB Listener for HTTP
resource "aws_alb_listener" "http_listener" {
  count             = var.create_alb == true ? 1 : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = var.target_group
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# Create Target Groups for ALB
resource "aws_alb_target_group" "target_group" {
  count                = var.create_target_group == true ? 1 : 0
  name                 = var.target_group_name
  port                 = var.port
  protocol             = var.protocol
  vpc_id               = var.vpc
  target_type          = var.tg_type
  deregistration_delay = var.alb_target_group_deregistration_delay

  health_check {
    enabled             = var.alb_target_group_health_check_enabled
    interval            = var.alb_target_group_health_check_interval
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.protocol
    timeout             = var.alb_target_group_health_check_timeout
    healthy_threshold   = var.alb_target_group_health_check_healthy_threshold
    unhealthy_threshold = var.alb_target_group_health_check_unhealthy_threshold
    matcher             = var.alb_target_group_health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name        = var.target_group_name
      Description = var.target_group_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}
