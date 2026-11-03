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
      Project     = "how-ec2-gets-a-role"
      ManagedBy   = "terraform"
    }
  }

} 
# only EC2 instances can assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# role for EC2 instances to assume
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = aws_iam_policy_document.ec2_trust.json
}
# persmission attachment for EC2 role to use SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

