
# # Create backend S3 bucket
# resource "aws_s3_bucket" "state_bucket" {
#   bucket = "papi-dev-terraform-bucket"

#   tags = {
#     Name = "local_state_bucket"

#   }
# }

# # Enable versioning for the bucket
# resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
#   bucket = aws_s3_bucket.state_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Enable server side encryption.
# resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_SSC" {
#   bucket = aws_s3_bucket.state_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }




# # Create DynamoDB resource for lock and consistency

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }










module "VPC" {
  source                              = "./modules/VPC"
  region                              = var.region
  vpc_cidr                            = var.vpc_cidr
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  preferred_number_of_public_subnets  = var.preferred_number_of_public_subnets
  preferred_number_of_private_subnets = var.preferred_number_of_private_subnets
  private_subnets                     = [for i in range(3, 7, 1) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets                      = [for i in range(1, 3, 1) : cidrsubnet(var.vpc_cidr, 8, i)]
}

module "Security" {
  source = "./modules/Security"
  vpc_id = module.VPC.vpc_id
}

module "ALB" {
  source         = "./modules/ALB"
  ext_lb_name    = var.ext_lb_name
  ex_LB_sg       = module.Security.ext-alb-sg
  public_subnet1 = module.VPC.public_subnet1
  public_subnet2 = module.VPC.public_subnet2
  nginx_target   = var.nginx_target
  vpc_id         = module.VPC.vpc_id
  int_lb_name    = var.int_lb_name
  int_lb_SG      = module.Security.int-ALB-SG
  private_sub1   = module.VPC.private_sub1
  private_sub2   = module.VPC.private_sub2
  wordpress_tgt  = var.wordpress_tgt
  target_type    = var.target_type
  tooling-tgt    = var.tooling-tgt

}

module "Autoscaling" {
  source            = "./modules/Autoscaling"
  nginx-alb-tgt     = module.ALB.nginx-tgt
  wordpress-alb-tgt = module.ALB.wordpress-tgt
  bastion-SG        = [module.Security.bastion-SG]
  ami-bastion       = var.ami-bastion
  ami-nginx         = var.ami-nginx
  ami-webservers    = var.ami-webservers
  instance_pfp      = module.VPC.instance_pfp
  public_subnet1    = module.VPC.public_subnet1
  public_subnet2    = module.VPC.public_subnet2
  private_subnet1   = module.VPC.private_sub1
  private_subnet2   = module.VPC.private_sub2
  nginx-sg          = [module.Security.nginx-SG]
  keypair           = var.keypair
  webservers-sg     = [module.Security.webservers-SG]
  tooling_alb_tgt   = module.ALB.tooling-tgt
  #   public_subnets    = [module.VPC.public_subnet1, module.VPC.public_subnet2] 
  #   private_subnets   = [module.VPC.private_sub1, module.VPC.private_sub2]
}

module "EFS" {
  source              = "./modules/EFS"
  datalayer-SG        = module.Security.datalayer-SG
  efs_private_subnet1 = module.VPC.private_sub1
  efs_private_subnet2 = module.VPC.private_sub2
  account_no          = var.account_no
}

module "RDS" {
  source          = "./modules/RDS"
  datalayer-SG    = [module.Security.datalayer-SG]
  master-password = var.master-password
  master-username = var.master-username
  private_subnets = [module.VPC.private_sub3, module.VPC.private_sub4]
}


module "compute" {
  source          = "./modules/Compute"
  subnets-compute = module.VPC.public_subnet1
  sg-compute      = [module.Security.ext-alb-sg]
  keypair         = var.keypair
  ami-compute     = var.ami-compute     
  ami-webservers = var.ami-webservers
  ami-nginx = var.ami-nginx
  ami-bastion = var.ami-bastion
}