variable "name" {
  type        = string
  description = "A name used to prefix all resources"
}

variable "app_repository" {
  type = object({
    owner  = string
    name   = string
    branch = string
  })
  description = "Application source repository"
}

variable "infra_repository" {
  type = object({
    url    = string
    branch = string
    key    = string
  })
  description = "Infrastructure source repository"
}

variable "codestar_connection_arn" {
  type        = string
  description = "CodeStar Connection ARN"
}

variable "manifest_path" {
  type        = string
  description = "Path to Kubernetes manifests"
}
