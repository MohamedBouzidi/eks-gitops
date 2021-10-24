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