provider "aws" {
    region = var.region
    profile = var.profile
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
}

resource "aws_launch_configuration" "first" {
    image_id = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance-sg.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, Africa" > index.html
                nohup busybox httpd -f -p var.server_port &
                EOF

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_security_group" "instance-sg" {
    name = "terraform-first-instance-sg"
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
      create_before_destroy = true
    }

    tags = {
        Name = "allow_web"
    }
}

data "aws_availability_zones" "new" {
  filter {
    name   = "opt-in-status"
    values = ["us-east-1a"]
  }
}

resource "aws_autoscaling_group" "first-ag" {
    launch_configuration = aws_launch_configuration.first.id
    availability_zones = data.aws_availability_zones.new.names

    min_size = 2
    max_size = 10

    tag {
      key = "Name"
      value = "my-first-terraform-asg"
      propagate_at_launch = true
    }
}

resource "aws_elb" "my_first_elb" {

  name = "my-first-terraform-asg"
  availability_zones = data.aws_availability_zones.new.names
  security_groups = aws_security_group.elb.id

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:var.server_port/"
  }
  
}

resource "aws_security_group" "elb" {
  name = "terraform-asg-elb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

