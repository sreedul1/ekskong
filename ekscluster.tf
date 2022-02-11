
resource "aws_eks_cluster" "main_ekscluster" {

  name                      = var.cluster_name ## cluster_name defined in variable.tf
  role_arn                  = aws_iam_role.eks-cluster-role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version                   = var.cluster_version
  tags                      = var.tags

  vpc_config {
    security_group_ids      = [aws_security_group.main_eksclustersg.id]
    subnet_ids              = var.eks_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access

  }


  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.main_ekscluster.name
  node_group_name = "${var.cluster_name}-${var.environment_id}-node_group-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.eks_subnet_ids
  instance_types  = var.instance_types
  disk_size       = var.disk_size
  tags            = var.tags

# remote_access {
#   ec2_ssh_key = var.ssh_key
# }
 
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_security_group.main_eksclustersg,
  ]
}


