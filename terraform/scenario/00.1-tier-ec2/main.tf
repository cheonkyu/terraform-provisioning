provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = var.name
  region = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Terraform   = true
    environment = var.environment
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  azs    = local.azs

  name = local.name
  cidr = local.vpc_cidr
  # private은 NAT G/W를 통해 외부 요청이 가능한 서브넷
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  # intra는 격리된 네트워크
  # intra_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT instance를 쓴다
  enable_nat_gateway = false
  single_nat_gateway = false

  # VPC flow
  # vpc_flow_log_iam_role_name            = "${local.name}-role"
  # vpc_flow_log_iam_role_use_name_prefix = true
  # enable_flow_log                       = true
  # create_flow_log_cloudwatch_log_group  = false
  # create_flow_log_cloudwatch_iam_role   = false
  # flow_log_max_aggregation_interval     = 600

  tags = local.tags
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = var.name # "nat-instance-${name}" prefix가 있음
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags              = local.tags
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "single-instance"
  ami                         = "ami-0fa42ed59eb46290d"
  instance_type               = "t2.micro"
  monitoring                  = true
  subnet_id                   = element(module.vpc.private_subnets, 0)
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

  vpc_id = module.vpc.vpc_id
  # security_group_ids = [module.sg_ssm.security_group_id]

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = module.vpc.private_subnets
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
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}

module "sg_ssm" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-ssm-ec2"
  description = "Security Group for EC2 Instance SSM"

  vpc_id = module.vpc.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

