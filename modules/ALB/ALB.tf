# Create external ALB for reverse proxy
resource "aws_lb" "ext-alb" {
  name     = var.ext_lb_name
  internal = false
  security_groups = [
    var.ex_LB_sg
  ]

  subnets = [
    var.public_subnet1,
    var.public_subnet2
  ]

  tags = merge(
    var.tags,
    {
      Name = var.ext_lb_name
    },
  )

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

# To inform our external ALB to where route the traffic we need to create a Target Group to point to its targets:
resource "aws_lb_target_group" "nginx-tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = var.nginx_target
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

# Then create a listener for the target group
resource "aws_lb_listener" "nginx-listener" {
  load_balancer_arn = aws_lb.ext-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.techzeus.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt.arn
  }
}

# Create the Internal Loadbalancer for webservers

resource "aws_lb" "int-alb" {
  name     = var.int_lb_name
  internal = true
  security_groups = [
    var.int_lb_SG,
  ]

  subnets = [
    var.private_sub1,
    var.private_sub2
  ]

  tags = merge(
    var.tags,
    {
      Name = var.int_lb_name
    },
  )
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

# Create Wordpress target group. This will be the default target group traffic will be routed
resource "aws_lb_target_group" "wordpress-tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = var.wordpress_tgt
  port        = 443
  protocol    = "HTTPS"
  target_type = var.target_type
  vpc_id      = var.vpc_id
}

# create target group for tooling server
resource "aws_lb_target_group" "tooling-tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = var.tooling-tgt
  port        = 443
  protocol    = "HTTPS"
  target_type = var.target_type
  vpc_id      = var.vpc_id
}

# Create a listener for this target group
# The internal load balancer will be serving 2 webservers i.e the wordpress and tooling webserver
# A listener will first be created for the wordpress whuch is the default
# A rule will be created to route traffic to tooling server when the host header changes

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.int-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.techzeus.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-tgt.arn
  }
}

# listener rule
resource "aws_lb_listener_rule" "tooling-listener" {
  listener_arn = aws_lb_listener.web-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling-tgt.arn
  }

  condition {
    host_header {
      values = ["tooling.techzeus.com"]
    }
  }
}