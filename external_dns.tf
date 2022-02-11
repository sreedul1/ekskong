resource "helm_release" "external_dns" {
  depends_on = [kubernetes_namespace.external-dns]
  chart      = var.external_dns_helm_chart_name
  namespace  = var.external_dns_namespace
  name       = var.external_dns_helm_release_name
  version    = var.external_dns_helm_chart_version
  repository = "../../../charts/"  # var.external_dns_helm_repo_url
  cleanup_on_fail = true

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

 set {
    name  = "clusterName"
    value = data.aws_eks_cluster.cluster.name
  }

  set {
    name  = "provider"
    value =  var.dns_provider
  }  

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "awsPreferCname"
    value = "true"
  }
  
  set {
    name  = "txtPrefix"
    value = "txt."
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.external_dns_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}