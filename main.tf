terraform {
  required_version = ">= 1.0.0"
  backend "remote" {
    organization = "magicfruit0"

    workspaces {
      name = "default"
    }
  }
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
  repository_name        = split(".git", local.repository_path_chunks[1])[0]
  manifest_path          = "infra/manifests"
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

module "build" {
  source        = "./modules/build"
  name          = var.name
  manifest_path = local.manifest_path
  codestar_connection_arn = var.codestar_connection_arn
  repository = {
    owner  = local.repository_owner
    name   = local.repository_name
    branch = var.repository_branch
  }
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
    manifest_path  = local.manifest_path
    namespace      = "default"
    key            = var.repository_key
  }
  adminPassword = "helloAdmin123"
}
