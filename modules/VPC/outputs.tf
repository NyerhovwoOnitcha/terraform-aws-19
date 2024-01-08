output "vpc_id" {
  value = aws_vpc.main.id
}

output "instance_pfp" {
  value = aws_iam_instance_profile.ip.id
}
output "public_subnets" {
  value = var.public_subnets
}

output "private_subnets" {
  value = var.private_subnets
  
}

output "public_subnet1" {
 value = aws_subnet.public[0].id
}

output "public_subnet2" {
 value = aws_subnet.public[1].id
}

output "private_sub1" {
 value = aws_subnet.private[0].id
}

output "private_sub2" {
 value = aws_subnet.private[1].id
}

output "private_sub3" {
 value = aws_subnet.private[2].id
}

output "private_sub4" {
  value = aws_subnet.private[3].id
}
