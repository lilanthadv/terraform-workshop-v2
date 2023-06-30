# Database Variables
database_name            = "ditto"
database_schema          = "public"
database_master_username = "postgres"
database_master_password = "czhv87ea2gil_prod"
database_port            = 5432

# Database Bastion Host Variables
bastion_host_key_pair_name = "bastionhost"

# ECS Variables
# ECS ALB Variables
ecs_alb_ssl_certificate_arn = "arn:aws:acm:ap-southeast-2:642801335081:certificate/266992e2-0f7a-4066-b15f-dae1649522ec"

# ECS Task Definition Variables
ecs_taks_definition_host_port                = 8000
ecs_taks_definition_cpu                      = 1024
ecs_taks_definition_memory                   = 4096
ecs_taks_definition_access_key               = "AKIAZLKPR7MU3R2FN5GX"
ecs_taks_definition_secret_key               = "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"
ecs_taks_definition_env_cognito_redirect_uri = "https://dittoflow.com/cb"
ecs_taks_definition_env_front_end_url        = "https://dittoflow.com"
ecs_taks_definition_env_ses_email            = "no-reply@dittosoftware.com"

# ECS Service Variables
ecs_service_container_port = 8000

# Cognito User Pool Variables
cognito_lambda_config_pre_sign_up_arn    = "arn:aws:lambda:ap-southeast-2:642801335081:function:autoConfirm_ditto_workflow_dev"
cognito_lambda_config_custom_message_arn = "arn:aws:lambda:ap-southeast-2:642801335081:function:work_flow_reset_password_staging"

# Cognito Google 
cognito_google_configurations_client_id     = "198930728399-cp287otkh21l80hdjs7bsqe6h2bv7i3b.apps.googleusercontent.com"
cognito_google_configurations_client_secret = "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"

# Cognito Microsoft 
cognito_microsoft_configuration_client_id     = "4b2a6342-3204-40ea-a9b8-f6deda3fa854"
cognito_microsoft_configuration_client_secret = "f1U8Q~R~w-eje.QAq1~gx1At9ubOGbHLKzjGKbo2"
cognito_microsoft_configuration_oidc_issuer   = "https://login.microsoftonline.com/b8410e4c-fbf3-4b8b-8e97-ecab19b58cb5/v2.0"


cognito_client_configuration_callback_urls = ["https://dittoflow.com/home", "https://dittoflow.com/cb"]
cognito_client_configuration_logout_urls   = ["https://dittoflow.com/login", "https://dittoflow.com/home"]

# Git Variables
# Server App Git 
server_app_git_connection_arn = "arn:aws:codestar-connections:ap-southeast-2:642801335081:connection/766a3241-e13c-4580-8720-292d76b51de3"
server_app_git_source_type    = "BITBUCKET"
server_app_git_repository_url = "https://bitbucket.org/dittosoftware/ditto-doc-api.git"
server_app_git_repository_id  = "dittosoftware/ditto-doc-api"
server_app_git_branch_name    = "master"

# Client App Git 
client_app_git_connection_arn = "arn:aws:codestar-connections:ap-southeast-2:642801335081:connection/766a3241-e13c-4580-8720-292d76b51de3"
client_app_git_source_type    = "BITBUCKET"
client_app_git_repository_url = "https://bitbucket.org/dittosoftware/ditto-doc-fe.git"
client_app_git_repository_id  = "dittosoftware/ditto-doc-fe"
client_app_git_branch_name    = "master"

# Client App Environment Variables
codebuild_client_app_env_api_url          = "https://prod-api.dittoflow.com"
codebuild_client_app_env_front_end_uri    = "https://app.dittoflow.com"
codebuild_client_app_env_stripe_key       = "pk_test_51M4KH6EGNesab9MOOoxD5b3LlqhAdgGzabdxCorfIiWVtlFVFyQLlaWXYnahsvDmKSnoGY0VUZeYyCAhHXdGzypA00oni0dHaX"
codebuild_client_app_env_pdf_service_url  = "https://staging-e2j-service.dittoflow.com/api/pdfviewer"
codebuild_client_app_env_word_service_url = "https://staging-e2j-service.dittoflow.com/api/DocumentEditor"
codebuild_client_app_env_syncfusion_key   = "Mgo+DSMBaFt+QHJqVEZrXVNbdV5dVGpAd0N3RGlcdlR1fUUmHVdTRHRcQltiQH5QdU1hWXlXdnY=;Mgo+DSMBPh8sVXJ1S0R+XVFPd11dXmJWd1p/THNYflR1fV9DaUwxOX1dQl9gSXhSf0VgWndccHNURmI=;ORg4AjUWIQA/Gnt2VFhiQlBEfV5AQmBIYVp/TGpJfl96cVxMZVVBJAtUQF1hSn5Vd0xjWnxWcnRSRGJe;MjQ1OTY5M0AzMjMxMmUzMDJlMzBlVmd5RnplSXdMVmxiUkova09EdUhMVnVHMjlsenpZRjVQOUVlUnRvNHpjPQ==;MjQ1OTY5NEAzMjMxMmUzMDJlMzBGelV2VlRhNnlxWFY0K1NTbUxNS3ZWc3BQY3JwL3FKTTNLOEVRT0krZWg0PQ==;NRAiBiAaIQQuGjN/V0d+Xk9FdlRDX3xKf0x/TGpQb19xflBPallYVBYiSV9jS31TcERqWXxdeHZVTmBfUw==;MjQ1OTY5NkAzMjMxMmUzMDJlMzBEM2JKeFhtOWNjM1Z2Z0N0aXNORXU4Y2djSy9pZXBQWFZOaGZQbTRrZllvPQ==;MjQ1OTY5N0AzMjMxMmUzMDJlMzBmVU9OQTBJV2hPeTFJcWlWYWpMMjlzREtlZUY0Q1J1N25zZE9teWI2ekk4PQ==;Mgo+DSMBMAY9C3t2VFhiQlBEfV5AQmBIYVp/TGpJfl96cVxMZVVBJAtUQF1hSn5Vd0xjWnxWcnRdTmVe;MjQ1OTY5OUAzMjMxMmUzMDJlMzBFQkxBcjBQdE5OMnptVS9LN2lsMkM0TDJTSStWbXBBRDBrNjNzTVFkNkNnPQ==;MjQ1OTcwMEAzMjMxMmUzMDJlMzBad04ra2p6RjZXdHhrYmlKbXA0U0NSajdIMFdYcUJnYnlFVkNaejQvREI4PQ==;MjQ1OTcwMUAzMjMxMmUzMDJlMzBEM2JKeFhtOWNjM1Z2Z0N0aXNORXU4Y2djSy9pZXBQWFZOaGZQbTRrZllvPQ=="
