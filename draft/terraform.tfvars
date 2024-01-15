region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

enable_dns_support = "true"

enable_dns_hostnames = "true"

preferred_number_of_public_subnets = 2

preferred_number_of_private_subnets = 4

tags = {
  owner-Email      = "papi@papi.io"
  Managed-By       = "Terraform"
  Billing-Accoount = "123456789"
}
keypair    = "papi"
ami        = "ami-0c7217cdde317cfec "
account_no = 597081703771

master-username = "cloudnloud"
master-password = "12345645578"
