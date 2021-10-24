variable "name" {
  type        = string
  description = "A name used to prefix all resources"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs of public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of private subnets"
}