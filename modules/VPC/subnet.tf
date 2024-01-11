# Get list of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# filter the list to return only zone and b
# data "aws_availability_zones" "available" {
#   state = "available"
#   filter {
#     name   = "zone-name"
#     values = ["${var.region}a", "${var.region}b"]
#   }
# }


# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PublicSubnet-%s", var.name, count.index)
    },
  )
}

# create private subnets
resource "aws_subnet" "private" {
  count      = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  # map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PrivateSubnet-%s", var.name, count.index)
    },
  )
}