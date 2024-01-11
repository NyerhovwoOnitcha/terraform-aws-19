# Create the backend configuration

# terraform {
#   backend "s3" {
#     bucket         = "papi-dev-terraform-bucket"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

terraform {
  backend "remote" {
   organization = "Pauly_DevOps"
   workspaces {
     name = "terraform-aws-19"
   }
  }
}