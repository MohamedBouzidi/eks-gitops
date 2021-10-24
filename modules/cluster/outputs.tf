output "name" {
  value = aws_eks_cluster.cluster.name
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "certificate" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
}