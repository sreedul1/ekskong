variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "environment_id" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "eks_vpc_id" {
  description = "VPC where the cluster and workers will be deployed"
  type        = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_subnet_ids" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "ssh_key" {
  description = "ssh key name to connect the worker nodes"
  type        = string
}

variable "instance_types" {
  description = "List of instance types associated with the EKS Node Group"
  type        = list(string)
}

variable "disk_size" {
  description = "the Size of the root EBS block device for worker node"
  type        = number
}


variable "min_size" {
  description = "Minumum node count in node group"
  type        = number

}

variable "max_size" {
  description = "Max node count in node group"
  type        = number

}
variable "desired_size" {
  description = "Desired node count in node group"
  type        = number

}

variable "max_unavailable" {
  description = "Max node count in node group"
  type        = number

}

variable "tags" {
  description = "Tags to be applied to all resources created for the AWS resources"
  type        = map(string)
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "iam_path_cluster" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/"
}

variable "region" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}

variable "local-exec-interpreter" {
  description = "If provided, this is a list of interpreter arguments used to execute the command"
  type        = list(string)
  default     = ["/bin/bash", "-c"]
  #default     = ["PowerShell", "-Command"]

}

variable "profile" {
  description = "The AWS Profile used to provision the EKS Cluster"
  type        = string
  default     = null
}



################### kubernetes Dahsboard #####################


variable "kubernetes_namespace" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes namespace to deploy kubernetes dashboard controller."
}

variable "k8s_resources_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for kubernetes resources name. For example `tf-module-`"
}

variable "kubernetes_resources_labels" {
  type        = map(string)
  default     = {}
  description = "Additional labels for kubernetes resources."
}

variable "kubernetes_deployment_image_registry" {
  type    = string
  default = "kubernetesui/dashboard"
}

variable "kubernetes_deployment_image_tag" {
  type    = string
  default = "v2.2.0"
}

variable "kubernetes_deployment_metrics_scraper_image_registry" {
  type    = string
  default = "kubernetesui/metrics-scraper"
}

variable "kubernetes_deployment_metrics_scraper_image_tag" {
  type    = string
  default = "v1.0.6"
}

variable "kubernetes_deployment_node_selector" {
  type = map(string)
  default = {
    "kubernetes.io/os" = "linux"
  }
  description = "Node selectors for kubernetes deployment"
}

variable "kubernetes_deployment_tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))

  default = [
    {
      key      = "node-role.kubernetes.io/master"
      operator = "Equal"
      value    = ""
      effect   = "NoSchedule"
    }
  ]
}

variable "kubernetes_service_account_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes service account name."
}

variable "kubernetes_secret_certs_name" {
  type        = string
  default     = "kubernetes-dashboard-certs"
  description = "Kubernetes secret certs name."
}

variable "kubernetes_role_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes role name."
}

variable "kubernetes_role_binding_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes role binding name."
}

variable "kubernetes_deployment_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes deployment name."
}

variable "kubernetes_dashboard_deployment_args" {
  type = list(string)
  default = [
    "--auto-generate-certificates",
  ]
  description = "Kubernetes deployment args."
}

variable "kubernetes_service_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes service name."
}

variable "kubernetes_ingress_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes ingress name."
}

#variable "kubernetes_dashboard_csrf" {
#  type        = string
#  description = "CSRF token"
#}


############## ALB Controller ###################

variable "albc_namespace" {
  description = "Kubernetes namespace to deploy the AWS ALB Controller into."
  type        = string
  default     = "default"
}

variable "permissions_boundary" {
  description = "permissions_boundary arn for IAM roles."
  type        = string
  default     = ""
}

variable "albc_iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/level3role/"
}

variable "k8s_cluster_type" {
  description = "Can be set to `vanilla` or `eks`. If set to `eks`, the Kubernetes cluster will be assumed to be run on EKS which will make sure that the AWS IAM Service integration works as supposed to."
  type        = string
  default     = "eks"
}

variable "enabled" {
  description = "A conditional indicator to enable cluster-autoscale"
  type        = bool
  default     = true
}

variable "helm" {
  description = "The helm release configuration"
  type        = map(any)
  default = {
    repository      = "../../../charts/" 
    name            = "aws-load-balancer-controller"
    chart           = "aws-load-balancer-controller"
    namespace       = "kube-system"
    serviceaccount  = "aws-load-balancer-controller"
    cleanup_on_fail = true
  }
}

variable "petname" {
  description = "An indicator whether to append a random identifier to the end of the name to avoid duplication"
  type        = bool
  default     = true
}

variable "albc_name_prefix" {
  description = "ALB controller name prefix "
  type        = string
  default     = "albc"
}


################ External DNS ######################

variable "external_dns_namespace" {
  type        = string
  description = "The Kubernetes namespace in which the external-dns service account has been created."
  default     = "external-dns"
}

variable "external_dns_service_account_name" {
  type        = string
  description = "The Kubernetes external-dns service account name."
  default     = "external-dns"
}

variable "policy_allowed_zone_ids" {
  type        = list(string)
  default     = ["*"]
  description = "List of the Route53 zone ids for service account IAM role access"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://hub.helm.sh/charts/bitnami/external-dns"
}

variable "external_dns_helm_chart_name" {
  type        = string
  default     = "external-dns"
  description = "external-dns helm chart name to be installed"
}

variable "external_dns_helm_release_name" {
  type        = string
  default     = "external-dns"
  description = "external-dns helm release name."
}

variable "external_dns_helm_chart_version" {
  type        = string
  default     = "1.7.0"
  description = "Version of the Helm chart"
}

variable "external_dns_helm_repo_url" {
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
  description = "Helm repository"
}

variable "policy_assume_role_enabled" {
  type        = bool
  default     = false
  description = "Whether IRSA is allowed to assume role defined by assume_role_arn. Useful for hosted zones in another AWS account."
}

variable "dns_provider" {
  type        = string
  default     = "aws"
  description = "Cloud provider for external DNS"
}


############################# metrics-server  ################################

variable "metrics_server_helm_create_namespace" {
  type        = bool
  default     = true
  description = "Create the namespace if it does not yet exist"
}

variable "metrics_server_helm_chart_name" {
  type        = string
  default     = "metrics-server"
  description = "Helm chart name to be installed"
}

variable "metrics_server_helm_chart_version" {
  type        = string
  default     = "5.9.2"
  description = "Version of the Helm chart"
}

variable "metrics_server_helm_release_name" {
  type        = string
  default     = "metrics-server"
  description = "Helm release name"
}

variable "metrics_server_helm_repo_url" {
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
  description = "Helm repository"
}

variable "metrics_server_namespace" {
  type        = string
  default     = "kube-system"
  description = "The namespace in which the metrics-server service account has been created"
}

variable "metrics_server_settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://hub.helm.sh/charts/stable/metrics-server"
}

variable "values" {
  type        = string
  default     = ""
  description = "Additional yaml encoded values which will be passed to the Helm chart."
}

