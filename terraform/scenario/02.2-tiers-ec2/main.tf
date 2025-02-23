module "network" {
  source              = "./modules/network"
  name                = var.name
  environment         = var.environment
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  vpc_private_subnet  = true
  vpc_public_subnet   = true
  vpc_database_subnet = true
  nat_type            = "nat-instance"
}

module "db" {
  source                = "./modules/db"
  identifier            = "rds-instance"
  environment           = var.environment
  vpc_id                = module.network.id
  cidr_block            = module.network.cidr_block
  database_subnet_group = module.network.database_subnet_group
  username              = "dev"
  password              = "dev123!@#"
  depends_on            = [module.network]
}

module "server" {
  source                      = "./modules/server"
  name                        = var.name
  environment                 = var.environment
  private_subnets             = module.network.private_subnets
  private_subnets_cidr_blocks = module.network.private_subnets_cidr_blocks
  vpc_id                      = module.network.id
  depends_on                  = [module.network]
}
