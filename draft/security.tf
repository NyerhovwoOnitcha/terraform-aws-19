#Security group for external ALB which allows HTTP and HTTPS traffic from anywhere

resource "aws_security_group" "ext-alb-sg" {
  name        = "ext-alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "ext-alb-sg"
    },
  )
}

resource "aws_security_group_rule" "ext-ALB-HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ext-alb-sg.id
}

resource "aws_security_group_rule" "ext-ALB-HTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ext-alb-sg.id
}

resource "aws_security_group_rule" "ext-ALB-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.ext-alb-sg.id
}


#SECURITY GROUP FOR BASTION SERVER
resource "aws_security_group" "bastion-SG" {
  name        = "bastion"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "bastion-SG"
    },
  )
}

resource "aws_security_group_rule" "bastion-SGR-ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion-SG.id
}


resource "aws_security_group_rule" "bastion-SGR-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.bastion-SG.id
}

# SECURITY GROUP FOR REVERSE PROXY
resource "aws_security_group" "nginx-SG" {
  name   = "nginx-SG"
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "nginx-SG"
    },
  )
}

resource "aws_security_group_rule" "inbound-nginx-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion-SG.id
  security_group_id        = aws_security_group.nginx-SG.id
}

resource "aws_security_group_rule" "inbound-nginx-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext-alb-sg.id
  security_group_id        = aws_security_group.nginx-SG.id
}


resource "aws_security_group_rule" "nginx-SGR-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.nginx-SG.id
}

#SECURITY GROUP FOR INTERNAL LOAD BALANCER
resource "aws_security_group" "int-ALB-SG" {
  name   = "int-ALB-SG"
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "int-ALB-SG"
    },
  )
}

resource "aws_security_group_rule" "inbound-int-ALB-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx-SG.id
  security_group_id        = aws_security_group.int-ALB-SG.id
}


resource "aws_security_group_rule" "int-ALB-SGR-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.int-ALB-SG.id
}

#SECURITY GROUP FOR THE WEBSERVERS
resource "aws_security_group" "webservers-SG" {
  name   = "webservers-SG"
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "webservers-SG"
    },
  )
}

resource "aws_security_group_rule" "inbound-webserver-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.int-ALB-SG.id
  security_group_id        = aws_security_group.webservers-SG.id
}

resource "aws_security_group_rule" "inbound-webserver-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion-SG.id
  security_group_id        = aws_security_group.webservers-SG.id
}


resource "aws_security_group_rule" "webservers-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.webservers-SG.id
}

#DATA LAYER SECURITY GROUP
resource "aws_security_group" "datalayer-SG" {
  name   = "datalayer-SG"
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "datalayer-SG"
    },
  )
}

resource "aws_security_group_rule" "inbound-nfs-port" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webservers-SG.id
  security_group_id        = aws_security_group.datalayer-SG.id
}

resource "aws_security_group_rule" "inbound-mysql-bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion-SG.id
  security_group_id        = aws_security_group.datalayer-SG.id
}

resource "aws_security_group_rule" "inbound-mysql-webserver" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webservers-SG.id
  security_group_id        = aws_security_group.datalayer-SG.id
}