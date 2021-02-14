module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform-test"
  description = "Security group for testing terraform build"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [var.vpc_range]
  ingress_rules       = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = ingress_cidr_blocks
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
