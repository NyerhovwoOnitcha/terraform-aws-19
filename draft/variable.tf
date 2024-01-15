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
  default = null
}

variable "preferred_number_of_private_subnets" {
  default = null
}




variable "tags" {
  type    = map(string)
  default = {}
}

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