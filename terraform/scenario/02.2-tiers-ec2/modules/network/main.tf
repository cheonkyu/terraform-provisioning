locals {
  name   = var.name
  region = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Terraform   = true
    environment = var.environment
  }

  vpc_private_subnet  = var.vpc_private_subnet
  vpc_intra_subnet    = var.vpc_intra_subnet
  vpc_public_subnet   = var.vpc_public_subnet
  vpc_database_subnet = var.vpc_database_subnet
  nat_type            = var.nat_type
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  azs    = local.azs

  name = local.name
  cidr = local.vpc_cidr
  # private은 NAT G/W를 통해 외부 요청이 가능한 서브넷
  private_subnets = local.vpc_private_subnet ? [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)] : []
  # intra는 격리된 네트워크
  intra_subnets    = local.vpc_intra_subnet ? [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)] : []
  public_subnets   = local.vpc_public_subnet ? [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)] : []
  database_subnets = local.vpc_database_subnet ? [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 9)] : []

  create_database_subnet_group  = local.vpc_database_subnet
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT instance를 쓴다
  enable_nat_gateway = local.nat_type == "nat-gateway"
  single_nat_gateway = local.nat_type == "nat-gateway"

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
  # count  = local.nat_type == "nat-instance" && local.vpc_private_subnet && local.vpc_public_subnet ? 1 : 0

  name                        = var.name # "nat-instance-${name}" prefix가 있음
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  tags                        = local.tags
}

resource "aws_eip" "nat" {
  # count             = local.nat_type == "nat-instance" && local.vpc_private_subnet && local.vpc_public_subnet ? 1 : 0
  network_interface = module.nat.eni_id
  tags              = local.tags
  depends_on        = [module.nat]
}
