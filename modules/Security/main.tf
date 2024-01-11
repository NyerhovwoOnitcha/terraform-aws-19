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
