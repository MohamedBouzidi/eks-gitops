terraform {
  required_version = ">= 1.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
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
