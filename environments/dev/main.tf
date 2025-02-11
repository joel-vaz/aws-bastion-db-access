provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

module "security" {
  source = "../../modules/security"

  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "compute" {
  source = "../../modules/compute"

  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  bastion_sg_id   = module.security.bastion_sg_id
  alb_sg_id       = module.security.alb_sg_id
  webserver_sg_id = module.security.webserver_sg_id

  key_name        = module.security.bastion_key_name
  instance_type   = var.instance_type
  certificate_arn = var.certificate_arn
}

module "database" {
  source = "../../modules/database"

  environment     = var.environment
  project_name    = var.project_name
  private_subnets = module.vpc.private_subnet_ids
  database_sg_id  = module.security.database_sg_id
}
