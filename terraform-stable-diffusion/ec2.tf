#AMI
data "aws_ami" "deep_learning_ami" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"

    values = [ "Deep Learning AMI GPU PyTorch 1.13.1 (Amazon Linux 2)*" ]
  }
}

# Launch template
resource "aws_launch_template" "launch_template" {
  name = "${var.name}-launch-template"

  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 100
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.systems_manager.name
  }
  image_id = data.aws_ami.deep_learning_ami.id

  instance_market_options {
    market_type = "spot"
  }
  instance_type = var.ec2_instance_type

  network_interfaces {
    associate_public_ip_address = true
    subnet_id = aws_subnet.public.id
    security_groups = ["${aws_security_group.server.id}"]
  }

  placement {
    availability_zone = "ap-northeast-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-server"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = filebase64("./conf/userdata.sh")
}


# spot fleet
resource "aws_spot_fleet_request" "spot_fleet_request" {
  iam_fleet_role  = "${aws_iam_role.spot-fleet-role.arn}"
  spot_price      = "0.6"
  target_capacity = 1
  terminate_instances_with_expiration = true

  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.launch_template.id
      version = aws_launch_template.launch_template.latest_version
    }
  }
}

# eip
resource "aws_eip" "eip" {
  vpc = true
}

resource "null_resource" "associate_eip" {
  depends_on = [aws_spot_fleet_request.spot_fleet_request]

  provisioner "local-exec" {
    command = <<EOF
    sleep 180
    EIP=${aws_eip.eip.public_ip}
    REGION=ap-northeast-1
    INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=terraform-stable-diffusion-webUI-server" --query "Reservations[*].Instances[*].InstanceId" --output text)
    aws ec2 associate-address --instance-id $INSTANCE_ID --public-ip $EIP --region $REGION
    EOF
  }
}