# Database Configurations
database_name   = "ditto"
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

# Repository Configurations
git_source_type    = "BITBUCKET"
git_repository_url = "https://bitbucket.org/dittosoftware/ditto-doc-api.git"
git_connection_arn = "arn:aws:codestar-connections:ap-southeast-2:642801335081:connection/766a3241-e13c-4580-8720-292d76b51de3"
git_repository_id  = "dittosoftware/ditto-doc-api"
git_branch_name    = "master"
