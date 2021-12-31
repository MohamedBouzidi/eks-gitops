terraform {
  required_version = ">= 1.0.0"
  backend "remote" {
    organization = "mgt-dev"

    workspaces {
      name = "default"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
  }
}

provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.endpoint
    cluster_ca_certificate = module.cluster.certificate
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.name]
      command     = "aws"
      env = {
        AWS_PROFILE = "terraform"
      }
    }
  }
}

locals {
  app_repository_path_chunks = split("/", split("git@github.com:", var.app_repository.url)[1])
  app_repository_owner       = local.app_repository_path_chunks[0]
  app_repository_name        = split(".git", local.app_repository_path_chunks[1])[0]
  manifest_path              = "infra/manifests/app"
}

module "network" {
  source        = "./modules/network"
  name          = var.name
  network_range = "10.0.0.0/16"
  subnet_count  = 2
}

module "cluster" {
  source                        = "./modules/cluster"
  name                          = var.name
  vpc_id                        = module.network.vpc_id
  public_subnet_ids             = module.network.public_subnet_ids
  private_subnet_ids            = module.network.private_subnet_ids
  secrets_encryption_kms_key_id = var.secrets_key
  my_cidr_range                 = var.my_cidr_range
}

module "build" {
  source                  = "./modules/build"
  name                    = var.name
  manifest_path           = local.manifest_path
  codestar_connection_arn = var.codestar_connection_arn
  app_repository = {
    owner  = local.app_repository_owner
    name   = local.app_repository_name
    branch = var.app_repository.branch
  }

  infra_repository = {
    url    = var.infra_repository.url
    branch = var.infra_repository.branch
    key    = var.infra_repository.key
  }
}

module "delivery" {
  source     = "./modules/delivery"
  depends_on = [module.cluster]

  application = {
    repository_url = var.infra_repository.url
    manifest_path  = local.manifest_path
    namespace      = "default"
    key            = var.infra_repository.key
  }
  adminPassword = var.argocd_admin_password
}
