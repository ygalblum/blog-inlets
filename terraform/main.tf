resource "aws_iam_user" "user" {
  name = "inlets-automation"
}

resource "aws_iam_policy" "policy" {
  name = "inlets-automation"
  description = "Policy for inlets IAM user"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:TerminateInstances",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:CreateTags",
        "ec2:RunInstances",
        "ec2:DescribeInstanceStatus"
      ],
      "Resource": ["*"]
    }
  ]
}
EOT
}

resource "aws_iam_user_policy_attachment" "policy-attachment" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_access_key" "user_key" {
  user = aws_iam_user.user.name
}

