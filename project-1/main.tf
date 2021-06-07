provider "aws" {
    region = "us-east-1"
    access_key = "AKIATIZLLRH7UBQE6GSG"
    secret_key = "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"
  
}

#create vpc
resource "aws_vpc" "project" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "my-first" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    tags = {
        Name = "ubuntu"
    }
}

#create internet gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.project.id
}

#create route table
resource "aws_route_table" "proj_rt" {
    vpc_id = aws_vpc.project.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
       Name = "proj-route-table"
    }
}

#create subnet
resource "aws_subnet" "proj-subnet" {
    vpc_id = aws_vpc.project.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
    Name = "project-subnet"
    }
}

#associate subnet to the route table
resource "aws_route_table_association" "sub-route-table" {
    subnet_id = aws_subnet.proj-subnet.id
    route_table_id = aws_route_table.proj_rt.id
}

#create security group for port 22,80,443
resource "aws_security_group" "allow_web" {
    name = "allow_web_traffic"
    description = "Allow Web inbound traffic"
    vpc_id = aws_vpc.project.id

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
            description = "SSH"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        #-1 means any protocol
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_web"
    }
}

#create a network interface
resource "aws_network_interface" "web-nic" {
    subnet_id = aws_subnet.proj-subnet.id
    private_ips = ["10.0.1.50"]
    security_groups = [aws_security_group.allow_web.id]
}

#create elastic IP
resource "aws_eip" "one" {
    vpc = true
    network_interface = aws_network_interface.web-nic.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gw]
}