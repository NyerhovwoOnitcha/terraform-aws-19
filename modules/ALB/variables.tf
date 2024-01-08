variable "tags" {
  type    = map(string)
  default = {}
}

variable "ext_lb_name" {
  type    = string
  description = "EXT ALB NAME"
}

variable "ex_LB_sg" {
  description = "EXT ALB security group"
}

variable "public_subnet1" {
  type = number
  description = "public subnet 1"
}

variable "public_subnet2" {
  type = number
  description = "public subnet 2"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "nginx_target" {
    description = "nginx target group name"
  
}

variable "int_lb_name" {
    type = string
    description = "INT LB name"
  
}

variable "int_lb_SG" {
  description = "int lb security group"
}

variable "private_sub1" {
  type = number
  description = "private subnet1"
}

variable "private_sub2" {
  type = number
  description = "private subnet2"
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