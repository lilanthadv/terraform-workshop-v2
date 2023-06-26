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


variable "schema_attributes" {
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = bool
    mutable                  = bool
    required                 = bool
    string_attribute_constraints = object({
      min_length = number
      max_length = number
    })
  }))
  default = [
    {
      name                     = "email"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 256
      }
    }
  ]
}

variable "cognito_user_pool_client_generate_secret" {
  type        = bool
  description = "Cognito User Pool Client Generate Secret"
  default     = false
}

variable "cognito_user_pool_client_refresh_token_validity" {
  type        = number
  description = "Cognito User Pool Client Refresh Token Validity"
  default     = 30
}

variable "cognito_user_pool_client_access_token_validity" {
  type        = number
  description = "Cognito User Pool Client Access Token Validity"
  default     = 1
}

variable "cognito_user_pool_client_id_token_validity" {
  type        = number
  description = "Cognito User Pool Client Id Token Validity"
  default     = 1
}

variable "cognito_user_pool_client_enable_token_revocation" {
  type        = bool
  description = "Cognito User Pool Client Enable Token Revocation"
  default     = true
}

variable "cognito_user_pool_client_prevent_user_existence_errors" {
  type        = string
  description = "Cognito User Pool Client Prevent User Existence Errors"
  default     = "ENABLED"
}

variable "cognito_user_pool_client_explicit_auth_flows" {
  type        = list(string)
  description = "Cognito User Pool Client Explicit Auth Flows"
  default = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

variable "cognito_user_pool_supported_identity_providers" {
  type        = list(string)
  description = "Cognito User Pool Client Supported Identity Providers"
  default     = ["COGNITO", "Google", "Microsoft"]
}

variable "cognito_user_pool_allowed_oauth_flows" {
  type        = list(string)
  description = "Cognito User Pool Client Allowed OAuth flows"
  default     = ["code"]
}

variable "cognito_user_pool_allowed_oauth_scopes" {
  type        = list(string)
  description = "Cognito User Pool Client Allowed OAuth Scopes"
  default     = ["aws.cognito.signin.user.admin", "openid", "email", "profile"]
}


