terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}

provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

module "network" {
  source        = "./modules/network"
  name          = var.name
  network_range = "10.0.0.0/16"
  subnet_count  = 2
}

module "cluster" {
  source             = "./modules/cluster"
  name               = var.name
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}