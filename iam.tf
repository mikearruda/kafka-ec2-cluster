resource "aws_iam_instance_profile" "kafka_profile" {
  name = "test_profile"
  role = aws_iam_role.kafka_role.name
}

resource "aws_iam_role" "kafka_role" {
  name = "kafka_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ec2-describe-instances" {
  name   = "kafka_describe_instances_policy"
  role   = aws_iam_role.kafka_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}