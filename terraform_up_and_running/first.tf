provider "aws" {
    region = "us-east-1"
    access_key = "AKIATIZLLRH7RSUM5PGE"
    secret_key = "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"
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

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    default = 8080
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