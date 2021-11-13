terraform {
  required_version = ">= 1.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster.endpoint
    cluster_ca_certificate = var.cluster.certificate
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster.name]
      command     = "aws"
      env = {
        AWS_PROFILE = var.aws_profile
      }
    }
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.adminPassword)
  }
}

resource "helm_release" "application" {
  name  = "application"
  chart = "./modules/delivery/application"

  set {
    name  = "repository_url"
    value = var.application.repository_url
  }

  set {
    name  = "manifest_path"
    value = var.application.manifest_path
  }

  set {
    name  = "namespace"
    value = var.application.namespace
  }

  set {
    name  = "repository_key"
    value = file(var.application.key)
  }
}
