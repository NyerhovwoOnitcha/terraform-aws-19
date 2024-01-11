# Create launch template for bastion
resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names
}

resource "aws_launch_template" "bastion-launch-template" {
  image_id               = var.ami-bastion
  instance_type          = var.instance_type
  vpc_security_group_ids = var.bastion-SG

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
        Name = "bastion-launch-template"
      },
    )
  }

  user_data = filebase64("${path.module}/bastion.sh")
}

#############################################################
# Launch template for nginx reverse proxy
#######################################

resource "aws_launch_template" "nginx-launch-template" {
  image_id               = var.ami-nginx
  instance_type          = var.instance_type
  vpc_security_group_ids = var.nginx-sg

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
        Name = "nginx-launch-template"
      },
    )
  }

  user_data = filebase64("${path.module}/nginx.sh")
}
