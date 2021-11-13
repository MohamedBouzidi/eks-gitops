variable "name" {
  type        = string
  description = "Name prefix for resources"
  default     = "EKS-GitOps"
}

variable "repository_url" {
  type        = string
  description = "Repository URl to build and deploy"
}

variable "repository_branch" {
  type        = string
  description = "Repository branch to build and deploy"
}

variable "repository_key" {
  type        = string
  description = "Repository SSH key file path"
}

variable "codestar_connection_arn" {
  type        = string
  description = "CodeStar Connection ARN"
}

variable "argocd_admin_password" {
  type        = string
  description = "ArgoCD Admin password"
  sensitive   = true
}

variable "secrets_key" {
  type        = string
  description = "AWS KMS key for encrypting Kubernetes secrets"
  sensitive   = true
}

variable "my_cidr_range" {
  type        = string
  description = "Network range for cluster administration"
  validation {
    condition     = cidrsubnet(var.my_cidr_range, 0, 0) == var.my_cidr_range
    error_message = "The network range should be a CIDR."
  }
}
