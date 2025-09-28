provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source                    = "./vpc"
  tags                      = local.project_tags
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  availability_zone         = var.availability_zone
  private_subnet_cidr_block = var.private_subnet_cidr_block
  db_subnet_cidr_block      = var.db_subnet_cidr_block
}