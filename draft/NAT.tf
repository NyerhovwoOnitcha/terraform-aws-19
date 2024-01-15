
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.allocation_id
  depends_on    = [aws_internet_gateway.gw]
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = merge(
    var.tags,
    {
      Name = format("%s-NAT", var.name)
    }
  )

}