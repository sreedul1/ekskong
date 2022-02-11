data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main_ekscluster.name
}

data "aws_region" "current" {}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "main_ekscluster" {
  name = var.cluster_name
  depends_on = [
    aws_eks_cluster.main_ekscluster,
  ]
}
