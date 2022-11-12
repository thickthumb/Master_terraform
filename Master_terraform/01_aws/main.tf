terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4GOLYPOHTY5YS4WR"
  secret_key = "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"
}

# Create a VPC
resource "aws_vpc" "new" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "name" = "main new vpc"
  }

}

#creating a subnet
resource "aws_subnet" "web1" {
    cidr_block = var.web_subnet
    vpc_id = aws_vpc.new.id
    availability_zone = "us-east-1a"
  tags = {
    "name" = "subnet new web"
  }
}

resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.new.id
  tags = {
    "name" = "${var.main_vpc_name} IGW"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.new.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    "name" = "my_default_rt"
  }
}

resource "aws_default_security_group" "def_sec_grp" {
  vpc_id = aws_vpc.new.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.my_public_ip]
  }


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
tags = {
  "Name" = "def sec grp"
}

}

  resource "aws_key_pair" "new_key" {
    key_name = "testing_ssh_key"
    public_key = file(var.ssh_public_key)
    
  }


resource "aws_instance" "my_vm1" {
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.web1.id
  vpc_security_group_ids = [aws_default_security_group.def_sec_grp.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.new_key.key_name
  tags = {
    "name" = "my new ec2"
  }
}
  


