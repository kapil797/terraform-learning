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
  name               = "ec  2-role"
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

 