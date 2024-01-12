
# create instance for jenkins
resource "aws_instance" "Jenkins" {
  ami                         = var.ami-compute
  instance_type               = "t2.medium"
  subnet_id                   = var.public_subnet1
  vpc_security_group_ids      = var.bastion-SG
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
  vpc_security_group_ids      = var.bastion-SG
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
  vpc_security_group_ids      = var.bastion-SG
  associate_public_ip_address = true
  key_name                    = var.keypair


  tags = merge(
    var.tags,
    {
      Name = "ACS-artifactory"
    },
  )
}