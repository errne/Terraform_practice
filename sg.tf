module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform-test"
  description = "Security group for testing terraform build"
  vpc_id      = "vpc-769ba010"

  ingress_cidr_blocks = ["172.31.0.0/16"]
  ingress_rules       = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "172.31.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
