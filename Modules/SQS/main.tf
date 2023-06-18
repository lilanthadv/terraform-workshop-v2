/*=================================================
  AWS SQS
===================================================*/

# Create SQS Queue
resource "aws_sqs_queue" "queue" {
  name = "${var.service.resource_name_prefix}-${var.name}"

  fifo_queue            = var.fifo_queue
  deduplication_scope   = var.deduplication_scope
  fifo_throughput_limit = var.fifo_throughput_limit

  visibility_timeout_seconds = var.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size

  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  content_based_deduplication = var.content_based_deduplication

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}

