

resource "kubernetes_service_account" "albc" {
  automount_service_account_token = true
  metadata {
    name      = lookup(var.helm, "name", "aws-load-balancer-controller")
    namespace = local.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.albc.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "albc" {
  metadata {
    name = lookup(var.helm, "name", "aws-load-balancer-controller")

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "albc" {
  metadata {
    name = lookup(var.helm, "name", "aws-load-balancer-controller")

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.albc.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.albc.metadata[0].name
    namespace = kubernetes_service_account.albc.metadata[0].namespace
  }
}

## kubernetes aws-load-balancer-controller

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-load-balancer-controller")
}

resource "helm_release" "lbc" {
  depends_on = [
    aws_eks_cluster.main_ekscluster,
    aws_eks_node_group.node_group,
    kubernetes_cluster_role_binding.albc,
  ]
  count           = var.enabled ? 1 : 0
  name            = lookup(var.helm, "name", "aws-load-balancer-controller")
  chart           = lookup(var.helm, "chart", "aws-load-balancer-controller")
  version         = lookup(var.helm, "version", null)
  repository      = lookup(var.helm, "repository", "../../../charts/") #"https://aws.github.io/eks-charts"
  namespace       = local.namespace
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "serviceAccount.create"                                     = false
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.albc.arn
      "region"                                                    = var.region
      "vpcId"                                                     = var.eks_vpc_id
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}