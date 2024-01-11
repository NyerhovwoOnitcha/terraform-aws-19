variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "enable_dns_support" {
  default = "true"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "preferred_number_of_public_subnets" {
}

variable "preferred_number_of_private_subnets" {
  
}

variable "public_subnets" {
  type = list(any)
  description = "list of public subnets"
}

variable "private_subnets" {
  type = list(any)
  description = "list of public subnets"
}




variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  type    = string
  default = "ACS"
}