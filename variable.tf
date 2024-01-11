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

variable "instance_type" {
  description = "the instance type"
}


variable "name" {
  type    = string
  default = "ACS"
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

variable "ami-jenkins" {
    type = string
    description = "ami for jenkins"
}
variable "ami-jfrog" {
    type = string
    description = "ami for jfrob"
}
variable "ami-sonar" {
    type = string
    description = "ami for sonar"
}

variable "ami-bastion" {
    type = string
    description = "ami for bastion"
}


variable "ami-nginx" {
    type = string
    description = "ami for nginx"
}


variable "ami-webservers" {
    type = string
    description = "ami for webservers"
}
