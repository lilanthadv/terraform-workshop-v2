/*====================================
  AWS Cognito User Pool
======================================*/

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.service.resource_name_prefix}-${var.name}"

  username_attributes = var.username_attributes

  lambda_config {
    pre_sign_up    = var.lambda_config.pre_sign_up_arn
    custom_message = var.lambda_config.custom_message_arn
  }

  dynamic "schema" {
    for_each = var.schema_attributes
    content {
      name                     = schema.value["name"]
      attribute_data_type      = schema.value["attribute_data_type"]
      developer_only_attribute = schema.value["developer_only_attribute"]
      mutable                  = schema.value["mutable"]
      required                 = schema.value["required"]

      dynamic "string_attribute_constraints" {
        for_each = [schema.value["string_attribute_constraints"]]
        content {
          min_length = string_attribute_constraints.value["min_length"]
          max_length = string_attribute_constraints.value["max_length"]
        }
      }
    }
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
    Terraform   = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "client" {

  depends_on = [aws_cognito_user_pool.user_pool, aws_cognito_identity_provider.google, aws_cognito_identity_provider.microsoft]

  name = "${var.service.resource_name_prefix}-${var.name}-client"

  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = var.cognito_user_pool_client_generate_secret

  refresh_token_validity = var.cognito_user_pool_client_refresh_token_validity
  access_token_validity  = var.cognito_user_pool_client_access_token_validity
  id_token_validity      = var.cognito_user_pool_client_id_token_validity

  enable_token_revocation       = var.cognito_user_pool_client_enable_token_revocation
  prevent_user_existence_errors = var.cognito_user_pool_client_prevent_user_existence_errors

  callback_urls = var.client_configuration.callback_urls
  logout_urls   = var.client_configuration.logout_urls

  explicit_auth_flows = var.cognito_user_pool_client_explicit_auth_flows

  supported_identity_providers = var.cognito_user_pool_supported_identity_providers

  allowed_oauth_flows = var.cognito_user_pool_allowed_oauth_flows

  allowed_oauth_scopes = var.cognito_user_pool_allowed_oauth_scopes
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "cognito_domain" {
  domain       = var.service.resource_name_prefix
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

# Cognito Identity Provider Google
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = var.google_configurations.authorize_scopes
    client_id        = var.google_configurations.client_id
    client_secret    = var.google_configurations.client_secret
  }

  attribute_mapping = {
    email_verified     = "email_verified"
    "custom:firstName" = "given_name"
    "custom:lastName"  = "family_name"
    name               = "name"
    email              = "email"
    username           = "sub"
  }
}

# Cognito Identity Provider Microsoft
resource "aws_cognito_identity_provider" "microsoft" {
  user_pool_id  = aws_cognito_user_pool.user_pool.id
  provider_name = "Microsoft"
  provider_type = "OIDC"

  provider_details = merge(
    {
      authorize_scopes          = var.microsoft_configuration.authorize_scopes
      client_id                 = var.microsoft_configuration.client_id
      client_secret             = var.microsoft_configuration.client_secret
      oidc_issuer               = var.microsoft_configuration.oidc_issuer
      attributes_request_method = var.microsoft_configuration.attributes_request_method
    },
    var.microsoft_configuration.authorize_url != "" ? { authorize_url = var.microsoft_configuration.authorize_url } : {},
    var.microsoft_configuration.attributes_url != "" ? { attributes_url = var.microsoft_configuration.attributes_url } : {},
    var.microsoft_configuration.jwks_uri != "" ? { jwks_uri = var.microsoft_configuration.jwks_uri } : {}
  )

  attribute_mapping = {
    email_verified     = "email_verified"
    "custom:firstName" = "given_name"
    "custom:lastName"  = "family_name"
    name               = "name"
    email              = "email"
    username           = "sub"
  }
}
