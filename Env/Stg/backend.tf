terraform {
  backend "s3" {
    bucket         = "ditto-doc-software-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "ditto-doc-software-terraform-state-staging"
  }
}
