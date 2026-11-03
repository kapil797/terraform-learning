# 1. Trust policy: only EC2 instances can assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# 2. Role for EC2 instances to assume
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}
# 3. Permissions: an AWS-managed policy (written and maintained by AWS)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# 4. The badge holder
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
# 5. Custom policy for S3 access
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app_data.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.app_data.arn}/*"]
  }
}
#create a custom policy for S3 access
resource "aws_iam_policy" "lab4-app-data-read-write" {
  name   = "lab4-app-data-read-write"
  policy = data.aws_iam_policy_document.s3_policy.json
}
#attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "s3_custom_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.lab4-app-data-read-write.arn
}
 