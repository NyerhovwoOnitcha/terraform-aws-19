variable "account_no" {
  description = "user account id/number"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "efs_private_subnet1" {
  description = "first subnet for mount target"
}

variable "efs_private_subnet2" {
  description = "second subnet for mount target"
}

variable "datalayer-SG" {
  description = "data layer security group.id"
}