# security group rule for ext ALB
resource "aws_security_group_rule" "ext-ALB-HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ACS["ext-alb-sg"].id
}

resource "aws_security_group_rule" "ext-ALB-HTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ACS["ext-alb-sg"].id
}

#########################################
# SECURITY GROUP RULE FOR BASTION SERVER
############################################
resource "aws_security_group_rule" "bastion-SGR-ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ACS["bastion-SG"].id
}

#################################################################
# SECURITY GROUP RULE FOR REVERSE PROXY
#######################################################################

resource "aws_security_group_rule" "inbound-nginx-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["bastion-SG"].id
  security_group_id        = aws_security_group.ACS["nginx-SG"].id
}

resource "aws_security_group_rule" "inbound-nginx-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["ext-alb-sg"].id
  security_group_id        = aws_security_group.ACS["nginx-SG"].id
}

#################################################################
# SECURITY GROUP RULE FOR INTERNAL LOAD BALANCER
##################################################################

resource "aws_security_group_rule" "inbound-int-ALB-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id =  aws_security_group.ACS["nginx-SG"].id
  security_group_id        = aws_security_group.ACS["int-ALB-SG"].id
}

############################################################
# SECURITY GROUP RULE FOR THE WEBSERVERS
##########################################################

resource "aws_security_group_rule" "inbound-webserver-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["int-ALB-SG"].id
  security_group_id        = aws_security_group.ACS["webservers-SG"].id
}

resource "aws_security_group_rule" "inbound-webserver-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["bastion-SG"].id
  security_group_id        = aws_security_group.ACS["webservers-SG"].id
}

##########################################################################
# DATA LAYER SECURITY GROUP RULE
###########################################################################

resource "aws_security_group_rule" "inbound-nfs-port" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["webservers-SG"].id
  security_group_id        = aws_security_group.ACS["datalayer-SG"].id
}

resource "aws_security_group_rule" "inbound-mysql-bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["bastion-SG"].id
  security_group_id        = aws_security_group.ACS["datalayer-SG"].id
}

resource "aws_security_group_rule" "inbound-mysql-webserver" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ACS["webservers-SG"].id
  security_group_id        = aws_security_group.ACS["datalayer-SG"].id
}

