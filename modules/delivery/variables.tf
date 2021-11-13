variable "aws_profile" {
  type        = string
  description = "AWS profile to access EKS cluster"
}

variable "cluster" {
  type = object({
    name        = string
    endpoint    = string
    certificate = string
  })
  description = "Kubernetes cluster connection information"
}

variable "adminPassword" {
  type        = string
  description = "ArgoCD admin password"
  sensitive   = true
}

variable "application" {
  type = object({
    repository_url = string
    manifest_path  = string
    namespace      = string
    key            = string
  })
  description = "ArgoCD application"
}
