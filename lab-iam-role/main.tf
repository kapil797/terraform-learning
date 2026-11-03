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
      Project     = "lab-iam-role"
      ManagedBy   = "terraform"
    }
  }
}
data "aws_caller_identity" "current" {}
# TRUST POLICY: the guest list. Only MY IAM user may assume this role.
data "aws_iam_policy_document" "trust_me" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS" #aws identity not service
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}
# PERMISSIONS POLICY: what the badge opens. Only listing buckets.
data "aws_iam_policy_document" "list_buckets_only" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}
resource "aws_iam_role" "lab_read_only" {
  name               = "lab-list-buckets-only"
  assume_role_policy = data.aws_iam_policy_document.trust_me.json
}

resource "aws_iam_role_policy" "list_bucket_only" {
  name   = "list_bucket_only"
  role   = aws_iam_role.lab_read_only.id
  policy = data.aws_iam_policy_document.list_buckets_only.json
}

output "role_arn" {
  value = aws_iam_role.lab_read_only.arn
}