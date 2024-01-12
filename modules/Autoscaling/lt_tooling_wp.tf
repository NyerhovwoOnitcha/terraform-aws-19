# launch template for wordpress

resource "aws_launch_template" "wordpress-launch-template" {
  image_id               = var.ami-webservers
  instance_type          = "t2.medium"
  vpc_security_group_ids = var.webservers-sg

  iam_instance_profile {
    name = var.instance_pfp
  }

  key_name = var.keypair

  placement {
    availability_zone = "{random_shuffle.az_list.result}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "wordpress-launch-template"
      },
    )

  }

  user_data = filebase64("${path.module}/wordpress.sh")
}
###########################################################################
# launch template for toooling
resource "aws_launch_template" "tooling-launch-template" {
  image_id               = var.ami-webservers
  instance_type          = "t2.medium"
  vpc_security_group_ids = var.webservers-sg

  iam_instance_profile {
    name = var.instance_pfp
  }

  key_name = var.keypair

  placement {
    availability_zone = "{random_shuffle.az_list.result}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "tooling-launch-template"
      },
    )

  }

  user_data = filebase64("${path.module}/tooling.sh")
}
