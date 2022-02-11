#### OIDC Provider
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main_ekscluster.identity.0.oidc.0.issuer
}
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.main_ekscluster.identity.0.oidc.0.issuer
}


##### VPC_CNI

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
}



