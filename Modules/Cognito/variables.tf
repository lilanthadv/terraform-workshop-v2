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
  type        = string
  description = "The name of your security resource"
}

variable "description" {
  type        = string
  description = "The description"
}

variable "username_attributes" {
  type        = list(string)
  description = "The Username Attributes"
  default     = ["email"]
}


variable "lambda_config" {
  type = object({
    pre_sign_up_arn    = string
    custom_message_arn = string
  })
  description = "Lambda Config"
}

variable "google_configurations" {
  type = object({
    authorize_scopes = optional(string, "profile email openid")
    client_id        = string
    client_secret    = string
  })
  description = "Google Identity Provider configurations"
}

variable "microsoft_configuration" {
  description = "Microsoft Identity Provider configurations"

  type = object({
    authorize_scopes          = optional(string)
    client_id                 = string
    client_secret             = string
    oidc_issuer               = string
    attributes_request_method = optional(string)
    authorize_url             = optional(string)
    attributes_url            = optional(string)
    jwks_uri                  = optional(string)
  })

  default = {
    authorize_scopes          = "profile email openid"
    client_id                 = ""
    client_secret             = ""
    oidc_issuer               = ""
    attributes_request_method = "GET"
    authorize_url             = ""
    attributes_url            = ""
    jwks_uri                  = ""
  }
}

variable "client_configuration" {
  description = "Cognito User Pool Client Configurations"

  type = object({
    callback_urls = list(string)
    logout_urls   = list(string)
  })
}

