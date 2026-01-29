provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source                    = "../../modules/vpc"
  project_name              = var.project_name
  environment               = var.environment
  vpc_cidr                  = var.vpc_cidr
  public_subnets_cidr       = var.public_subnets_cidr
  private_app_subnets_cidr  = var.private_app_subnets_cidr
  private_data_subnets_cidr = var.private_data_subnets_cidr
  availability_zones        = var.availability_zones
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "efs" {
  source              = "../../modules/efs"
  project_name        = var.project_name
  environment         = var.environment
  private_app_subnets = module.vpc.private_app_subnet_ids
  security_group_id   = module.security.data_sg_id
}

module "rds" {
  source                 = "../../modules/rds"
  project_name           = var.project_name
  environment            = var.environment
  private_data_subnets   = module.vpc.private_data_subnet_ids
  vpc_security_group_ids = [module.security.data_sg_id]
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
}

module "elasticache" {
  source               = "../../modules/elasticache"
  project_name         = var.project_name
  environment          = var.environment
  private_data_subnets = module.vpc.private_data_subnet_ids
  security_group_ids   = [module.security.data_sg_id]
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_sg_id
}

module "asg" {
  source              = "../../modules/asg"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_app_subnets = module.vpc.private_app_subnet_ids
  security_group_id   = module.security.app_sg_id
  target_group_arn    = module.alb.target_group_arn
  instance_type       = var.instance_type
  efs_id              = module.efs.efs_id
  db_host             = module.rds.endpoint
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  redis_host          = module.elasticache.primary_endpoint_address
  redis_port          = module.elasticache.port
}
