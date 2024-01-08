variable "region" {

}

variable "vpc_cidr" {

}

variable "enable_dns_support" {
  default = "true"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "preferred_number_of_public_subnets" {
  default = null
}

variable "preferred_number_of_private_subnets" {
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}


variable "nginx_target" {
  description = "nginx target group name"

}

variable "int_lb_name" {
  type        = string
  description = "INT LB name"

}

# variable "int_lb_SG" {
#   description = "int lb security group"
# }

# variable "private_sub1" {
#   description = "private subnet1"
# }

# variable "private_sub2" {
#   description = "private subnet2"
# }

variable "wordpress_tgt" {
  description = "wordress target group name"
}

variable "tooling-tgt" {
  description = "tooling target group name"
}

variable "target_type" {
  description = "target group resource type"
}

variable "ext_lb_name" {
  type        = string
  description = "EXT ALB NAME"
}

# variable "ex_LB_sg" {
#   description = "EXT ALB security group"
# }

# variable "public_subnet1" {
#   description = "public subnet 1"
# }

# variable "public_subnet2" {
#   description = "public subnet 2"
# }

# variable "nginx-alb-tgt" {
#   description = "nginx-reverse proxy target group arn"
# }

# variable "wordpress-alb-tgt" {
#   description = "wordpress target group arn"
# }

# variable "bastion-SG" {
#   description = "bastion security group ID"
# }

variable "instance_type" {
  description = "the instance type"
}

# variable "instance_pfp" {
#   description = "instance profile id"
# }

# variable "efs_private_subnet1" {
#   description = "first subnet for mount target"
# }

# variable "efs_private_subnet2" {
#   description = "second subnet for mount target"
# }

# variable "datalayer-SG" {
#   description = "data layer security group.id"
# }

# variable "private_subnets" {
#   description = "Private subnets for DB subnets group"
# }



variable "name" {
  type    = string
  default = "ACS"
}

variable "ami" {
  type        = string
  description = "AMI ID for the launch template"
}

variable "keypair" {
  type        = string
  description = "key pair for the instances"
}

variable "account_no" {
  type = number

}

variable "master-username" {
  type = string
}

variable "master-password" {
  type = string
}