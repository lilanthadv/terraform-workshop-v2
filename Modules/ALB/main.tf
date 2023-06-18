/*==============================================================
      AWS Application Load Balancer + Target groups
===============================================================*/

# ALB
resource "aws_alb" "alb" {
  count              = var.create_alb == true ? 1 : 0
  name               = "${var.service.resource_name_prefix}-${var.name}"
  subnets            = [var.subnets[0], var.subnets[1]]
  security_groups    = [var.security_group]
  load_balancer_type = "application"
  internal           = false
  enable_http2       = true
  idle_timeout       = 30

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}

# ALB Listenet for HTTPS
resource "aws_alb_listener" "https_listener" {
  count             = var.create_alb == true ? (var.enable_https == true ? 1 : 0) : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    target_group_arn = var.target_group
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# ALB Listener for HTTP
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

# Target Groups for ALB
resource "aws_alb_target_group" "target_group" {
  count                = var.create_target_group == true ? 1 : 0
  name                 = "${var.service.resource_name_prefix}-${var.name}-tg"
  port                 = var.port
  protocol             = var.protocol
  vpc_id               = var.vpc
  target_type          = var.tg_type
  deregistration_delay = 5

  health_check {
    enabled             = true
    interval            = 15
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.protocol
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}-tg"
    Description = "${var.description} Target Group"
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}
