variable "name" {
  type        = string
  description = "A name used to prefix all resources"
}

variable "repository" {
  type = object({
    owner  = string
    name   = string
    branch = string
  })
  description = "Repository information to build"
}

variable "codestar_connection_arn" {
  type        = string
  description = "CodeStar Connection ARN"
}

variable "manifest_path" {
  type        = string
  description = "Path to Kubernetes manifests"
}