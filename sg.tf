data "aws_ssm_parameter" "home_ip" {
  name = "Home_ip"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name     = "allow_tls"
    Function = "Testing Terraform sg resource"
  }
}

resource "aws_security_group_rule" "allow_tls_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_range]
  security_group_id = aws_security_group.allow_tls.id
  description       = "TLS from VPC"
}

resource "aws_security_group_rule" "allow_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_ssm_parameter.home_ip.value]
  security_group_id = aws_security_group.allow_tls.id
  description       = "HTTP from Home"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_tls.id
}
