#IAM Role
resource "aws_iam_instance_profile" "test_profile" {
  name = "tf_test_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "tf_test_role2"
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

# IAM Policy and attachment
data "aws_iam_policy" "EC2SSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm-role-policy-attach" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.EC2SSM.arn
}


module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "test"

  # Launch template
  launch_template_name    = aws_launch_template.test.name
  launch_template_version = "$Latest"

  # Auto scaling group
  asg_name                  = "tf"
  vpc_zone_identifier       = ["subnet-ca266182", "subnet-f2bcc894"]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 0
  wait_for_capacity_timeout = 0

  tags = {
    Environment = "dev"
    Project     = "Terraform"
    Name        = "Tf-test"
    extra_tag1  = "extra_value1"
    extra_tag2  = "extra_value2"
    extra_tag3  = "extra_value3"
  }
}
