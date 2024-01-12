# output "security_groups" {
#   value = aws_security_group.ACS[*].id
# }

output "bastion-SG" {
  value = aws_security_group.ACS["bastion-SG"].id
}

output "ext-alb-sg" {
  value = aws_security_group.ACS["ext-alb-sg"].id
}

output "int-ALB-SG" {
  value = aws_security_group.ACS["int-ALB-SG"].id
}

output "webservers-SG" {
  value = aws_security_group.ACS["webservers-SG"].id
}

output "datalayer-SG" {
  value = aws_security_group.ACS["datalayer-SG"].id
}

output "nginx-SG" {
  value = aws_security_group.ACS["nginx-SG"].id
}

