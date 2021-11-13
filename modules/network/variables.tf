variable "name" {
  type        = string
  description = "Prefix for name"
}

variable "network_range" {
  type        = string
  description = "CIDR for VPC"
  validation {
    condition     = cidrsubnet(var.network_range, 0, 0) == var.network_range
    error_message = "The network range should be a CIDR."
  }
}

variable "subnet_count" {
  type        = number
  description = "Number of public/private subnet pairs"
}
