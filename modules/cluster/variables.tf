variable "name" {
  type        = string
  description = "A name used to prefix all resources"
}

variable "my_cidr_range" {
  type        = string
  description = "Network range for cluster administration"
  validation {
    condition     = cidrsubnet(var.my_cidr_range, 0, 0) == var.my_cidr_range
    error_message = "The network range should be a CIDR."
  }
}

variable "secrets_encryption_kms_key_id" {
  type        = string
  description = "AWS KMS CMK ID to encrypt Kubernetes secrets"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs of public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of private subnets"
}
