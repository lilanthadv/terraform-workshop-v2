output "id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "endpoint" {
  value = aws_cognito_user_pool.user_pool.endpoint
}

output "domain" {
  value = aws_cognito_user_pool.user_pool.domain
}

output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "provider_google_id" {
  value = aws_cognito_identity_provider.google.id
}

