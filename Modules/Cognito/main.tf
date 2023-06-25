/*====================================
  AWS Cognito User Pool
======================================*/

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.service.resource_name_prefix}-${var.name}"

  username_attributes = var.username_attributes

  password_policy {
    minimum_length = 6
  }

  lambda_config {
    pre_sign_up    = var.lambda_config.pre_sign_up_arn
    custom_message = var.lambda_config.custom_message_arn
  }

  # Predefined attribute
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Custom attribute
  schema {
    name                     = "firstName"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                     = "lastName"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = {
    Name        = "${var.service.resource_name_prefix}-${var.name}"
    Description = var.description
    Service     = var.service.app_name
    Environment = var.service.app_environment
    Version     = var.service.app_version
    User        = var.service.user
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "client" {
  name = coalesce(var.client_configuration.name, "${var.service.resource_name_prefix}-${var.name}-client")

  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = var.client_configuration.generate_secret

  refresh_token_validity = var.client_configuration.refresh_token_validity
  access_token_validity  = var.client_configuration.access_token_validity
  id_token_validity      = var.client_configuration.id_token_validity

  enable_token_revocation       = var.client_configuration.enable_token_revocation
  prevent_user_existence_errors = var.client_configuration.prevent_user_existence_errors

  explicit_auth_flows = var.client_configuration.explicit_auth_flows

  callback_urls = var.client_configuration.callback_urls
  logout_urls   = var.client_configuration.logout_urls

  supported_identity_providers = var.client_configuration.supported_identity_providers

  allowed_oauth_flows = var.client_configuration.allowed_oauth_flows

  allowed_oauth_scopes = var.client_configuration.allowed_oauth_scopes
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
