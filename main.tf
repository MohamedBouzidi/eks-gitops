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

locals {
  repository_path_chunks = split("/", split("git@github.com:", var.repository_url)[1])
  repository_owner       = local.repository_path_chunks[0]
  repository_name        = local.repository_path_chunks[1]
  repository_key         = file(var.repository_key)
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

module "delivery" {
  source      = "./modules/delivery"
  aws_profile = "terraform"
  cluster = {
    name        = module.cluster.name
    endpoint    = module.cluster.endpoint
    certificate = module.cluster.certificate
  }
  application = {
    repository_url = var.repository_url
    manifest_path  = "infra/manifests"
    namespace      = "default"
    key            = local.repository_key
  }
  adminPassword = "helloAdmin123"
}