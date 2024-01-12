# create instance for bastion
resource "aws_instance" "bastion" {
  ami                         = var.ami-bastion
  instance_type               = "t2.medium"
  subnet_id                  = var.private_subnet1
  vpc_security_group_ids      = var.bastion-SG
  associate_public_ip_address = true
  key_name                    = var.keypair

 tags = merge(
    var.tags,
    {
      Name = "ACS-bastion"
    },
  )
}

# create instance for nginx
resource "aws_instance" "nginx" {
  ami                         = var.ami-nginx
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet1
  vpc_security_group_ids      = var.nginx-SG
  associate_public_ip_address = true
  key_name                    = var.keypair

 tags = merge(
    var.tags,
    {
      Name = "ACS-nginx"
    },
  )
}

# create instance for wordpress
resource "aws_instance" "wordpress" {
  ami                         = var.ami-webservers
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet1
  vpc_security_group_ids      = var.webservers-SG
  associate_public_ip_address = true
  key_name                    = var.keypair

 tags = merge(
    var.tags,
    {
      Name = "ACS-wordpress"
    },
  )
}

# create instance for tooling
resource "aws_instance" "tooling" {
  ami                         = var.ami-webservers
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet2
  vpc_security_group_ids      = var.webservers-SG
  associate_public_ip_address = true
  key_name                    = var.keypair

 tags = merge(
    var.tags,
    {
      Name = "ACS-tooling"
    },
  )
}


# create instance for jenkins
resource "aws_instance" "Jenkins" {
  ami                         = var.ami-compute
  instance_type               = "t2.medium"
  subnet_id                   = var.public_subnet1
  vpc_security_group_ids      = var.ext-alb-sg
  associate_public_ip_address = true
  key_name                    = var.keypair

 tags = merge(
    var.tags,
    {
      Name = "ACS-Jenkins"
    },
  )
}



#create instance for sonbarqube
resource "aws_instance" "sonbarqube" {
  ami                         = var.ami-compute
  instance_type               = "t2.medium"
  subnet_id                   = var.public_subnet1
  vpc_security_group_ids      = var.ext-alb-sg
  associate_public_ip_address = true
  key_name                    = var.keypair


   tags = merge(
    var.tags,
    {
      Name = "ACS-sonbarqube"
    },
  )
}

# create instance for artifactory
resource "aws_instance" "artifactory" {
  ami                         = var.ami-bastion
  instance_type               = "t2.medium"
  subnet_id                   = var.public_subnet1
  vpc_security_group_ids      = var.ext-alb-sg
  associate_public_ip_address = true
  key_name                    = var.keypair


  tags = merge(
    var.tags,
    {
      Name = "ACS-artifactory"
    },
  )
}