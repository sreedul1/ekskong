locals {
  cluster_name = data.aws_eks_cluster.cluster.id
}

######################### Kube dashbaord ################################

locals {
  kubernetes_resources_labels = merge({
    "kong-demo/terraform-module" = "kube-dashboard",
  }, var.kubernetes_resources_labels)

  kubernetes_deployment_labels_selector = {
    "kong-demo/application" = "kubernetes-dashboard",
  }

  kubernetes_deployment_labels_selector_metrics = {
    "kong-demo/application" = "kubernetes-dashboard",

  }

  kubernetes_deployment_labels         = merge(local.kubernetes_deployment_labels_selector, local.kubernetes_resources_labels)
  kubernetes_deployment_labels_metrics = merge(local.kubernetes_deployment_labels_selector_metrics, local.kubernetes_resources_labels)

  kubernetes_deployment_image                 = "${var.kubernetes_deployment_image_registry}:${var.kubernetes_deployment_image_tag}"
  kubernetes_deployment_metrics_scraper_image = "${var.kubernetes_deployment_metrics_scraper_image_registry}:${var.kubernetes_deployment_metrics_scraper_image_tag}"
}

######################### ALB Controller ################################

resource "random_string" "lbc-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && var.enabled ? random_string.lbc-suffix.0.result : ""
  name   = join("-", compact([var.cluster_name, "aws-load-balancer-controller", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}