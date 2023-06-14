# Create sqs queue
resource "aws_sqs_queue" "queue" {
  name = "${var.app_name}-${var.name}"

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
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}

