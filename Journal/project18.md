# Refactoring the terraform script
We will be making lost of changes to our configuration, to enabe us compare and contrast when we are done, duplicate your directory i.e `nPBL`. nPBL will contain the initial sketch script while the new directory `refactored` will have our updated config.


## Moving the Backend to s3
 Create an s3 bucket to move the backend to and create a dynamoDB table for locking


Terraform stores secret data in the state files e.g passwords and secret keys, this is why you must enable encryption with the `server_side_encryption_resource`  for the bucket.

Next is to create a DynamoDB table to handle locks and perform consistency checks, this was handled locally by the local file `terraform.tfstate.lock.info`

## Isolation Of Environments

we will need to create resources for different  environments, such as: Dev, sit uat, preprod, prod, etc.

This separation of environments can be achieved using one of two methods:

a. [Terraform Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)
b. Directory based separation using terraform.tfvars file

WHEN TO USE DIRECTORY OR OR WORKSPACES:

`To separate environments with significant configuration differences, use a directory structure. Use workspaces for environments that do not greatly deviate from each other, to avoid duplication of your configurations.`

## Refactoring of the script.
- Introduce modules 
- Use variables as much as possible to avoid hardcoing values and ..
- Refactor the script.

### Notable changes made to the code.

#### The way we created the subnets have changed.

In project 17 when creating the `public and private subnets` we tried as much as possible to not hardcode values to our arguments, we did a good job but we can better it since we are introducing a module.

The condition is still there that tells terraform how many times it goes into a loop but, instead of harcoding the `cidr block`, we put a variable there. Then when we call a variable when we call the `VPC module in the root main.tf file`

```
resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PublicSubnet-%s", var.name, count.index)
    },
  )
}

# create private subnets
resource "aws_subnet" "private" {
  count      = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  # map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PrivateSubnet-%s", var.name, count.index)
    },
  )
}
```

When we call the variable in the VPC module, we use a `for loop` to determine the `cidr block that will be passed to the public and private subnet variable`.

```
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
```

We already know that our 2 public subnets should be `10.0.1.0/16 & 10.0.2.0/16` and our 4 private subnets to be `10.0.3.0/16, 10.0.4.0/16, 10.0.5.0/16, 10.0.6.0/16`

The public subnet loop is saying that `for i in range 1-3 i.e between 1-3 increaing by 1 (= 1,2) use that with the cidrsubnet function to create the public subnets cidr blocks`

The private subnet loop is saying for `i in range 3-7 increaing by 1 (=3,4,5,6), use that cidrsubnet function to create the private subnets cidr blocks`

#### The Security Group resource

Formerly, when creating our security groups we used multiple identical resource blocks, we refactored this by first creating a local variable containing a map of all the security groups in the `security.tf file`, then we used a for `each loop` to loop over each of them and create the security group

```
resource "aws_security_group" "ACS" {
    for_each = local.security_group
    name = each.value["name"]
    description = each.value["description"]
    vpc_id = var.vpc_id

     egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    },
  )
}
```

#### consequently, you now know 3 ways to create subnets:

1- METHOD 1

`main.tf`
```
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = var.tag_name
  }
}

resource "aws_subnet" "main-subnet" {
  for_each = var.prefix

  availability_zone_id = each.value["az"]
  cidr_block           = each.value["cidr"]
  vpc_id               = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.basename}-subnet-${each.key}"
  }
}
```

`variable.tf`

```
variable "prefix" {
  type = map(any)
  default = {
    sub-1 = {
      az   = "use1-az1"
      cidr = "10.0.198.0/24"
    }
    sub-2 = {
      az   = "use1-az2"
      cidr = "10.0.199.0/24"
    }
    sub-3 = {
      az   = "use1-az3"
      cidr = "10.0.200.0/24"
    }
  }
}
```

2- METHOD 2
`main.tf`
```
data "aws_availability_zones" "available" {
  state = "available"
}

# filter the list to return only zone and b
# data "aws_availability_zones" "available" {
#   state = "available"
#   filter {
#     name   = "zone-name"
#     values = ["${var.region}a", "${var.region}b"]
#   }
# }


# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PublicSubnet-%s", var.name, count.index)
    },
  )
}

# create private subnets
resource "aws_subnet" "private" {
  count      = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  # map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PrivateSubnet-%s", var.name, count.index)
    },
  )
}
```

Where preferred_number_of_public_subnets and preferred_number_of_private_subnets is pre-determined. 

THE 3RD METHOD IS THE REFACTORING OF METHOD2 EXPLAINED AT THE START.

## NOTE on modules.

When you create a resource in a module and the output of that resource will be used elsewhere in another module or in another file, create an `output.tf file` and capture the output of that resource. if the output will be used in a different module then use a variable for it and finally, when you call the variable in the root main.tf file, the format for calling the output of the resource is: `module.module_name.output_namr`. example. 

Step 1- 
we created 6 security groups in the security module i.e ext_lb, bastion_sg,nginx_sg, int_lb, webservers_sg and datalayers_sg. These security groups will be used multiple times in other modules as we will be creating resouurces using them. Basically we know that resources in other modules will need these security groups ids, thus, we create an output.tf file to capture them:
```
output "bastion-SG" {
  value = "aws_security_group.ACS[bastion-SG].id"
}

output "ext-alb-sg" {
  value = "aws_security_group.ACS[ext-alb-sg].id"
}

output "int-ALB-SG" {
  value = "aws_security_group.ACS[int-ALB-SG].id"
}

output "webservers-SG" {
  value = "aws_security_group.ACS[webservers-SG].id"
}

output "datalayer-SG" {
  value = "aws_security_group.ACS[datalayer-SG ].id"
}

output "nginx-SG" {
  value = "aws_security_group.ACS[dnginx-SG ].id"
}
```
Step 2:
 we want to create a resource in ALB module that requires a the ext_lb security group id, we will use a variable that will be called when the module is called in the root module. notice how `security_groups = var.ex_LB_sg` and ` subnets =  var.public_subnet1, var.public_subnet2`. Declare them in the alb module's `variable.tf` file. 

```
resource "aws_lb" "ext-alb" {
  name     = var.ext_lb_name
  internal = false
  security_groups = [
    var.ex_LB_sg
  ]

  subnets = [
    var.public_subnet1,
    var.public_subnet2
  ]

  tags = merge(
    var.tags,
    {
      Name = var.ext_lb_name
    },
  )

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}
```

Step 3:
When you call the module in the root main.tf file and pass the variables:
The format is: `module.module_name.output_name`

```
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
```
Note that every variable passed in the module's variable.tf file is called and defined at the root module. 
The variables that are defined the way we did above are not passed in the root module's variablea.tf file as they have already been defined, but those yet to be defined e.g `var.tooling-tgt` are defined in the root module's variables.tf file and terraform.tfvars file respectively.


