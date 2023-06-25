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
    name                          = optional(string)
    generate_secret               = optional(bool)
    refresh_token_validity        = optional(number)
    access_token_validity         = optional(number)
    id_token_validity             = optional(number)
    enable_token_revocation       = optional(bool)
    prevent_user_existence_errors = optional(string)
    explicit_auth_flows           = optional(list(string))
    callback_urls                 = list(string)
    logout_urls                   = list(string)
    supported_identity_providers  = optional(list(string))
    allowed_oauth_flows           = optional(list(string))
    allowed_oauth_scopes          = optional(list(string))
  })

  default = {
    generate_secret               = false
    refresh_token_validity        = 30
    access_token_validity         = 1
    id_token_validity             = 1
    enable_token_revocation       = true
    prevent_user_existence_errors = "ENABLED"
    explicit_auth_flows = [
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_CUSTOM_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH",
      "ALLOW_USER_SRP_AUTH",
    ]
    callback_urls                = null
    logout_urls                  = null
    supported_identity_providers = ["COGNITO", "Google", "Microsoft"]
    allowed_oauth_flows          = ["code"]
    allowed_oauth_scopes         = ["aws.cognito.signin.user.admin", "openid", "email", "profile"]
  }

  validation {
    condition     = var.client_configuration.callback_urls != null && var.client_configuration.logout_urls != null
    error_message = "callback_urls and logout_urls are mandatory."
  }
}

