

resource "helm_release" "metrics_server" {
  
  chart            = var.metrics_server_helm_chart_name
  create_namespace = var.metrics_server_helm_create_namespace
  namespace        = var.metrics_server_namespace
  name             = var.metrics_server_helm_release_name
  version          = "3.7.0" #var.metrics_server_helm_chart_version
  repository       = "../../../charts/" #var.metrics_server_helm_repo_url

  values = [
    var.values
  ]

  dynamic "set" {
    for_each = var.metrics_server_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

