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
