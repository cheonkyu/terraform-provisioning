locals {
  name = var.name

  tags = {
    Terraform   = true
    environment = var.environment
  }
  vpc_id                      = var.vpc_id
  private_subnets             = var.private_subnets
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
}


module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "single-instance"
  ami                         = "ami-0fa42ed59eb46290d"
  instance_type               = "t2.micro"
  monitoring                  = true
  subnet_id                   = element(var.private_subnets, 0)
  create_spot_instance        = true
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.sg_ssm.security_group_id]
  user_data              = <<EOF
    #!/bin/bash
    sleep 20s
    systemctl restart amazon-ssm-agent.service
    EOF
  tags                   = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = local.vpc_id
  # security_group_ids = [module.sg_ssm.security_group_id]

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = local.private_subnets
      private_dns_enabled = false
      tags                = { Name = "${local.name}-${service}" }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = local.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}

module "sg_ssm" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-ssm-ec2"
  description = "Security Group for EC2 Instance SSM"

  vpc_id = local.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}
