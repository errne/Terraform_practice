resource "aws_launch_template" "test" {
  name_prefix   = "tf-test-"
  image_id      = "ami-04e7764922e1e3a57"
  instance_type = "t2.micro"
  key_name      = "spraktas"

  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }

  vpc_security_group_ids = ["sg-0176ce5ea22452d2e", aws_security_group.allow_tls.id]

  block_device_mappings {
    device_name = "/dev/xvdz"

    ebs {
      volume_size = 10
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp3"
    }
  }

  user_data = base64encode(file("userdata.sh"))

  tags = {
    Name = "tf-test-lt"
  }
}
