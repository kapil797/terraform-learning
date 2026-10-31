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
resource "aws_vpc" "lab2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "lab2_vpc"
  }
}
resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.lab2_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "lab2_public_${each.key}"
  }
}
resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.lab2_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = "lab2_private_${each.key}"
  }
}

resource "aws_internet_gateway" "lab2_igw" {
  vpc_id = aws_vpc.lab2_vpc.id
  tags = {
    Name = "lab2_igw"
  }
}
resource "aws_route_table" "lab2_public_rt" {
  vpc_id = aws_vpc.lab2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab2_igw.id
  }
  tags = {
    Name = "lab2_public_rt"
  }
}
resource "aws_route_table_association" "lab2_public_subnet_assoc" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.lab2_public_rt.id
}

resource "aws_route_table" "lab2_private_rt" {
  vpc_id = aws_vpc.lab2_vpc.id
  tags = {
    Name = "lab2_private_rt"
  }
}

resource "aws_route_table_association" "lab2_private_subnet_assoc" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.lab2_private_rt.id
}