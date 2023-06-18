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
  description = "The name of the deployed environment"
  type        = string
}

variable "description" {
  type        = string
  description = "The description"
}
