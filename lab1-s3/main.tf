terraform {
  required_version = "1.17.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
  default_tags {
       tags = {
         Project   = "tf-learning"
         Owner     = "kapil"
         ManagedBy = "terraform"
       }
  }
}

resource "aws_s3_bucket" "kapil-s3-bucket-006" {
  bucket = "kapil-s3-bucket-006"
}
# moved {
#   from = aws_s3_bucket.kapil-s3-bucket-007
#   to   = aws_s3_bucket.kapil-s3-bucket-006
# }
