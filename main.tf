terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    null = {
      source = "hashicorp/null"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
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

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/16"
}

# Creating an EC2 instance
resource "aws_instance" "ec2_test" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_ec2_access.id]
  count                  = 2

  depends_on = [aws_subnet.test_subnet]

  tags = {
    Name = "My Test Instance ${count.index}"
  }
}

# Creating a security group for the EC2 instance with one ingress and one egress rule
resource "aws_security_group" "test_ec2_access" {
  name        = var.sg_name
  description = "Allow TLS inbound HTTPS traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.test_vpc.cidr_block]
    description = var.sg_ingress
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating the null resource for local execution of the command which will show us the private IP of the second instance
resource "null_resource" "private_ip_test" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.ec2_test[1].private_ip} >> private-ip.txt"
  }
}