/*====================================
  AWS Cognito User Pool
======================================*/

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = var.cognito_user_pool_name

  username_attributes = var.username_attributes


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

  tags = merge(
    {
      Name        = var.cognito_user_pool_name
      Description = var.cognito_user_pool_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.cognito_user_pool_name}-client"

  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = var.cognito_user_pool_client_generate_secret

  refresh_token_validity = var.cognito_user_pool_client_refresh_token_validity
  access_token_validity  = var.cognito_user_pool_client_access_token_validity
  id_token_validity      = var.cognito_user_pool_client_id_token_validity

  enable_token_revocation       = var.cognito_user_pool_client_enable_token_revocation
  prevent_user_existence_errors = var.cognito_user_pool_client_prevent_user_existence_errors


  explicit_auth_flows = var.cognito_user_pool_client_explicit_auth_flows

  supported_identity_providers = var.cognito_user_pool_supported_identity_providers

  allowed_oauth_flows = var.cognito_user_pool_allowed_oauth_flows

  depends_on = [aws_cognito_user_pool.user_pool]
}

