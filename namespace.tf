resource "kubernetes_namespace" "esg-control" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  metadata {
    labels = {
      mylabel = "esg-control"
    }
    annotations = {
      "iam.amazonaws.com/permitted": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/.*"
      "externalsecrets.kubernetes-client.io/permitted-key-name": "${var.environment_id}/.*"
    }
    name = "esg-control"
  }
}

resource "kubernetes_namespace" "esg-data" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  metadata {
    labels = {
      mylabel = "esg-data"
    }
    annotations = {
      "iam.amazonaws.com/permitted": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/.*"
      "externalsecrets.kubernetes-client.io/permitted-key-name": "${var.environment_id}/.*"
    }
    name = "esg-data"
  }
}

resource "kubernetes_namespace" "es-workloads" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  metadata {
    labels = {
      mylabel = "es-workloads"
    }
    annotations = {
      "iam.amazonaws.com/permitted": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/.*"
      "externalsecrets.kubernetes-client.io/permitted-key-name": "${var.environment_id}/.*"
    }
    name = "es-workloads"
  }
}

resource "kubernetes_namespace" "external-secrets" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  metadata {
    labels = {
      mylabel = "external-secrets"
    }
    name = "external-secrets"
    annotations = {
      "iam.amazonaws.com/permitted": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/.*"
      "externalsecrets.kubernetes-client.io/permitted-key-name": "${var.environment_id}/.*"
    }
  }
}

resource "kubernetes_namespace" "external-dns" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
  ]
  metadata {
    labels = {
      mylabel = "external-dns"
    }
    annotations = {
      "iam.amazonaws.com/permitted": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/.*"
      "externalsecrets.kubernetes-client.io/permitted-key-name": "${var.environment_id}/.*"
    }
    name = "external-dns"
  }
}