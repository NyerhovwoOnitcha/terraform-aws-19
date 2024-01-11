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

instance_type = "t2.medium"

keypair    = "papi"
account_no = "597081703771"

master-username = "cloudnloud"
master-password = "12345645578"
ami-jfrog = ""
ami-sonar = "ami-0d99ff85fbddc282a"

ami-bastion = "ami-0b1170a74b18c6f77"
ami-nginx = " ami-0108d161909b997a1"
ami-jenkins = "ami-0d99ff85fbddc282a"
ami-webservers ="ami-0e9c42f139abde3c7"