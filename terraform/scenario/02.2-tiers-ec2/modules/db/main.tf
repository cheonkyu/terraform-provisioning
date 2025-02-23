locals {
  identifier = var.identifier
  name       = var.identifier

  username = var.username
  password = var.password
  tags = {
    Terraform   = true
    environment = var.environment
  }
  vpc_id                = var.vpc_id
  cidr_block            = var.cidr_block
  database_subnet_group = var.database_subnet_group
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.identifier

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  username = local.username
  password = local.password
  port     = 3306

  multi_az               = false
  db_subnet_group_name   = local.database_subnet_group
  vpc_security_group_ids = [module.sg_rds.security_group_id]
  # vpc_security_group_ids = [module.sg_rds.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = false

  skip_final_snapshot = true
  deletion_protection = false

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # create_monitoring_role = true
  # monitoring_interval    = 60

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = local.tags
  # db_instance_tags = {
  #   "Sensitive" = "high"
  # }
  # db_option_group_tags = {
  #   "Sensitive" = "low"
  # }
  # db_parameter_group_tags = {
  #   "Sensitive" = "low"
  # }
  # db_subnet_group_tags = {
  #   "Sensitive" = "high"
  # }
  # cloudwatch_log_group_tags = {
  #   "Sensitive" = "high"
  # }
}

module "sg_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "MySQL security group"
  vpc_id      = local.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = local.cidr_block
    },
  ]

  tags = local.tags
}

