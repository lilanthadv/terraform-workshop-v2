variable "cognito_user_pool_name" {
  type        = string
  description = "Cognito User Pool Name"
}

variable "cognito_user_pool_description" {
  type        = string
  description = "Cognito User Pool description"
}

variable "custom_tags" {
  description = "Tags"
  type        = map(string)
  default     = null

}

variable "username_attributes" {
  type        = list(string)
  description = "The Username Attributes"
  default     = ["email"]
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
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

variable "cognito_user_pool_supported_identity_providers" {
  type        = list(string)
  description = "Cognito User Pool Client Supported Identity Providers"
  default     = ["COGNITO"]
}

variable "cognito_user_pool_allowed_oauth_flows" {
  type        = list(string)
  description = "Cognito User Pool Client Allowed OAuth flows"
  default     = ["code"]
}



