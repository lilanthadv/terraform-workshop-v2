# Database Configurations
database_name   = "ditto"
database_schema = "public"
master_username = "postgres"
master_password = "czhv87ea2gil_prod"

# ECS Task Definition Configurations
docker_image_url = "642801335081.dkr.ecr.ap-southeast-2.amazonaws.com/ditto-com-docs-api-staging:6f55e916e142b32bee6a63838c5e765f9e716ab1"
container_port   = 8000
host_port        = 8000
cpu              = 1024
memory           = 4096
access_key       = "AKIAZLKPR7MU3R2FN5GX"
secret_key       = "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"

# Git Configurations
# Backend
backend_git_connection_arn = "arn:aws:codestar-connections:ap-southeast-2:642801335081:connection/766a3241-e13c-4580-8720-292d76b51de3"
backend_git_source_type    = "BITBUCKET"
backend_git_repository_url = "https://bitbucket.org/dittosoftware/ditto-doc-api.git"
backend_git_repository_id  = "dittosoftware/ditto-doc-api"
backend_git_branch_name    = "master"

# Frontend
frontend_git_connection_arn = "arn:aws:codestar-connections:ap-southeast-2:642801335081:connection/766a3241-e13c-4580-8720-292d76b51de3"
frontend_git_source_type    = "BITBUCKET"
frontend_git_repository_url = "https://bitbucket.org/dittosoftware/ditto-doc-fe.git"
frontend_git_repository_id  = "dittosoftware/ditto-doc-fe"
frontend_git_branch_name    = "master"

# Frontend Environment Values
react_app_api_url          = "https://prod-api.dittoflow.com"
react_app_front_end_uri    = "https://app.dittoflow.com"
react_app_stripe_key       = "pk_test_51M4KH6EGNesab9MOOoxD5b3LlqhAdgGzabdxCorfIiWVtlFVFyQLlaWXYnahsvDmKSnoGY0VUZeYyCAhHXdGzypA00oni0dHaX"
react_app_pdf_service_url  = "https://staging-e2j-service.dittoflow.com/api/pdfviewer"
react_app_word_service_url = "https://staging-e2j-service.dittoflow.com/api/DocumentEditor"
react_app_syncfusion_key   = "Mgo+DSMBaFt+QHJqVEZrXVNbdV5dVGpAd0N3RGlcdlR1fUUmHVdTRHRcQltiQH5QdU1hWXlXdnY=;Mgo+DSMBPh8sVXJ1S0R+XVFPd11dXmJWd1p/THNYflR1fV9DaUwxOX1dQl9gSXhSf0VgWndccHNURmI=;ORg4AjUWIQA/Gnt2VFhiQlBEfV5AQmBIYVp/TGpJfl96cVxMZVVBJAtUQF1hSn5Vd0xjWnxWcnRSRGJe;MjQ1OTY5M0AzMjMxMmUzMDJlMzBlVmd5RnplSXdMVmxiUkova09EdUhMVnVHMjlsenpZRjVQOUVlUnRvNHpjPQ==;MjQ1OTY5NEAzMjMxMmUzMDJlMzBGelV2VlRhNnlxWFY0K1NTbUxNS3ZWc3BQY3JwL3FKTTNLOEVRT0krZWg0PQ==;NRAiBiAaIQQuGjN/V0d+Xk9FdlRDX3xKf0x/TGpQb19xflBPallYVBYiSV9jS31TcERqWXxdeHZVTmBfUw==;MjQ1OTY5NkAzMjMxMmUzMDJlMzBEM2JKeFhtOWNjM1Z2Z0N0aXNORXU4Y2djSy9pZXBQWFZOaGZQbTRrZllvPQ==;MjQ1OTY5N0AzMjMxMmUzMDJlMzBmVU9OQTBJV2hPeTFJcWlWYWpMMjlzREtlZUY0Q1J1N25zZE9teWI2ekk4PQ==;Mgo+DSMBMAY9C3t2VFhiQlBEfV5AQmBIYVp/TGpJfl96cVxMZVVBJAtUQF1hSn5Vd0xjWnxWcnRdTmVe;MjQ1OTY5OUAzMjMxMmUzMDJlMzBFQkxBcjBQdE5OMnptVS9LN2lsMkM0TDJTSStWbXBBRDBrNjNzTVFkNkNnPQ==;MjQ1OTcwMEAzMjMxMmUzMDJlMzBad04ra2p6RjZXdHhrYmlKbXA0U0NSajdIMFdYcUJnYnlFVkNaejQvREI4PQ==;MjQ1OTcwMUAzMjMxMmUzMDJlMzBEM2JKeFhtOWNjM1Z2Z0N0aXNORXU4Y2djSy9pZXBQWFZOaGZQbTRrZllvPQ=="
