variable "cluster_name" {
  description = "The Cluster Name"
  type        = string
}

variable "cluster_description" {
  type        = string
  description = "The Cluster Description"
}

variable "custom_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = null
}
