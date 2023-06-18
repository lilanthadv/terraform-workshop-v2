variable "service" {
  description = "Service details"
  type = object({
    app_name             = string
    app_environment      = string
    app_version          = string
    user                 = string
    resource_name_prefix = string
  })
}

variable "name" {
  description = "The name of your security resource"
  type        = string
}

variable "description" {
  type        = string
  description = "The description"
}

variable "fifo_queue" {
  type        = bool
  description = "The fifo queue"
}

variable "deduplication_scope" {
  type        = string
  description = "The deduplication scope"
}

variable "fifo_throughput_limit" {
  type        = string
  description = "The fifo throughput limit"
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout seconds"
}

variable "delay_seconds" {
  type        = number
  description = "The delay seconds"
}

variable "max_message_size" {
  type        = number
  description = "The max message size"
}

variable "message_retention_seconds" {
  type        = number
  description = "The message retention seconds"
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "The receive wait time seconds"
}

variable "content_based_deduplication" {
  type        = bool
  description = "The content based deduplication"
}
