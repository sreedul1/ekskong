provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

/*
## Update the kube configuration after the cluster has been created so we can connect to it and create the K8s resources

resource "null_resource" "kubeconfig" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${var.cluster_name} --region=${var.region} ${var.profile == null ? "" : format("--profile=%s", var.profile)}"
    interpreter = var.local-exec-interpreter
  }
}
*/
