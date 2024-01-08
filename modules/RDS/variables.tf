variable "datalayer-SG" {
  description = "data layer security group.id"
}

variable "master-username" {
  description = "DB username"
}

variable "master-password" {
  description = "DB password"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "private_subnets" {
  type = list(any)
  description = "Private subnets for DB subnets group"
}