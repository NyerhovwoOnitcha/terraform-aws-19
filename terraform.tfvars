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

nginx_target = "nginx-tgt"

int_lb_name   = "int-alb"
wordpress_tgt = "wordpress-tgt"

tooling-tgt = "tooling-tgt"

target_type = "instance"

ext_lb_name = "ext-alb"

# int_lb_SG = ""

# private_sub1 = ""

# private_sub2 = ""



# ex_LB_sg = ""

# public_subnet1 = ""

# public_subnet2 = ""

# nginx-alb-tgt = ""

# wordpress-alb-tgt = ""

# bastion-SG = ""

instance_type = "t2.micro"

# instance_pfp = ""

# efs_private_subnet1 = ""

# efs_private_subnet2 = ""

# datalayer-SG = ""

# private_subnets = ""






keypair    = "papi"
ami        = "ami-0c7217cdde317cfec "
account_no = 597081703771

master-username = "cloudnloud"
master-password = "12345645578"
