
output "eks_server_sg" {
  value = aws_security_group.main_eksclustersg.id
}

output "ca" {
  value = aws_eks_cluster.main_ekscluster.certificate_authority[0].data
}

output "endpoint" {
  value = aws_eks_cluster.main_ekscluster.endpoint
}