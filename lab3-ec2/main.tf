terraform {
  required_version = ">= 1.17, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
  default_tags {
    tags = {
      Owner       = "kapil"
      Environment = "lab"
      Project     = "lab2"
      ManagedBy   = "terraform"
    }
  }
}
locals {
  public_subnets = {
    a = {
      cidr_block = "10.0.1.0/24",
      az         = "ap-southeast-1a"
    }
    b = {
      cidr_block = "10.0.2.0/24",
      az         = "ap-southeast-1b"
    }
  }
  private_subnets = {
    a = {
      cidr_block = "10.0.20.0/24",
      az         = "ap-southeast-1a"
    }
    b = {
      cidr_block = "10.0.21.0/24",
      az         = "ap-southeast-1b"
    }
  }
}
resource "aws_vpc" "lab3_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "lab3_vpc"
  }
}
resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.lab3_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "lab3_public_${each.key}"
  }
}
resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.lab3_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = "lab3_private_${each.key}"
  }
}

resource "aws_internet_gateway" "lab3_igw" {
  vpc_id = aws_vpc.lab3_vpc.id
  tags = {
    Name = "lab3_igw"
  }
}
resource "aws_route_table" "lab3_public_rt" {
  vpc_id = aws_vpc.lab3_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab3_igw.id
  }
  tags = {
    Name = "lab3_public_rt"
  }
}
resource "aws_route_table_association" "lab3_public_subnet_assoc" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.lab3_public_rt.id
}

resource "aws_route_table" "lab3_private_rt" {
  vpc_id = aws_vpc.lab3_vpc.id
  tags = {
    Name = "lab3_private_rt"
  }
}

resource "aws_route_table_association" "lab3_private_subnet_assoc" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.lab3_private_rt.id
}
resource "aws_security_group" "lab3_sg" {
  name        = "lab3_sg"
  description = "Security group for lab3"
  vpc_id      = aws_vpc.lab3_vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.lab3_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol        = "tcp"
  cidr_ipv4      = "0.0.0.0/0"

}

data "aws_ssm_parameter" "lab3_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_instance" "lab3_instance" {
  ami           = data.aws_ssm_parameter.lab3_ami.value
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public["a"].id
  security_groups = [aws_security_group.lab3_sg.name]
  tags = {
    Name = "lab3_instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.lab3_instance.public_ip
}