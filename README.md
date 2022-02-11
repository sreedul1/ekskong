AWS EKS Terraform module

Amazon Elastic Kubernetes Service (Amazon EKS) is a managed service that you can use to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes. Kubernetes is an open-source system for automating the deployment, scaling, and management of containerized applications. Amazon EKS Runs and scales the Kubernetes control plane across multiple AWS Availability Zones to ensure high availability and automatically scales control plane instances based on load, detects and replaces unhealthy control plane instances, and it provides automated version updates and patching for them.

This module has several sub-modules to deploy kubernetes controllers and utilities.

Elastic Kubernetes Service 

    Create an EKS cluster on AWS. It will have a control plane and node groups as data plane.
    Create security groups that allow communication and coordination 
    Create IAM polices and roles for authentication
    Create AWS Load Balancer Controller
    Create kubernetes dashboard
    Amazon ECR for container images

Relational database 

    security groups for communication 
    parameter group for Postgresql rds
    subnetgroup for rds
    Postgresql relational database 


Modules :
    eks clsuter 
    Postgresql RDS 

Providers :

aws
kubernetes
helm


Install CLIs

AWS CLi   : 

aws ref : https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
tabcorp ref : https://myconfluence.tabcorp.com.au/pages/viewpage.action?spaceKey=GS&title=How+to+login+and+access+to+AWS+EKS+by+using+aws-adfs

eksctl :  aws ref : https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-eksctl.html

kubectl :  aws ref : https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

Terraform : terraform ref : https://learn.hashicorp.com/tutorials/terraform/install-cli


resource :

aws_eks_cluster.main_ekscluster    :  resource
aws_eks_node_group.node_group      :  resource
aws_security_group.main_eksclustersg : resource
aws_iam_role.eks-cluster-role       : resource
aws_iam_instance_profile.instance_profile : resource
aws_iam_role.server-cluster    : resource
aws_iam_role_policy_attachment.server-cluster-AmazonEKSClusterPolicy  : resource
aws_iam_role_policy_attachment.server-cluster-AmazonEKSVPCResourceController  : resource
aws_iam_role_policy_attachment.main-ekscluster-AmazonEKSServicePolicy  : resource
aws_iam_instance_profile.instance_profile : resource
aws_iam_role.node_group  :  resource
aws_iam_role_policy_attachment.node_group-AmazonEKSWorkerNodePolicy   :   resource
aws_iam_role_policy_attachment.node_group-AmazonEKS_CNI_Policy :  resource
aws_iam_role_policy_attachment.node_group-AmazonEC2ContainerRegistryReadOnly   : resource
aws_iam_role_policy_attachment.node_group-AmazonSSMManagedInstanceCore : resource
aws_iam_service_linked_role.elasticloadbalancing   : resource
aws_iam_role_policy_attachment.cluster_elb_sl_role_creation  : resource
aws_iam_policy.cluster_elb_sl_role_creation   : resource
aws_eks_addon.vpc_cni : resource
aws_iam_role.external-secrets-role  :  resource
aws_iam_policy.secrets_management_policy  :  resource
aws_iam_role_policy_attachment.secrets_management_policy_attachment : resource
kubernetes_namespace.esg-control : resource
kubernetes_namespace.esg-data  : resource
aws_iam_role.albc : resource 
aws_iam_policy.albc  : resource 
aws_iam_role_policy_attachment.albc   : resource
kubernetes_service_account.albc   : resource
kubernetes_cluster_role.albc : resource
kubernetes_cluster_role_binding.albc : resurce
helm_release.lbc   : resource
kubernetes_namespace.kubernetes_dashboard : resource
kubernetes_service_account.kubernetes_dashboard : resource
kubernetes_secret.k8s_dashboard_certs  : resource
kubernetes_secret.k8s_dashboard_csrf  : resource
kubernetes_secret.k8s_dashboard_key_holder : resource
kubernetes_config_map.kubernetes_dashboard_settings : resource
kubernetes_role.kubernetes_dashboard : resource
kubernetes_role_binding.kubernetes_dashboard   : resource
kubernetes_cluster_role.kubernetes_dashboard  : resource
kubernetes_cluster_role_binding.kubernetes_dashboard  : resource
kubernetes_deployment.kubernetes_dashboard  : resource
kubernetes_deployment.kubernetes_metrics_scraper  : resource
kubernetes_service.kubernetes_dashboard  : resource
kubernetes_service.kubernetes_metrics_scraper  : resource
aws_eks_cluster.cluster  : data source
aws_subnet_ids.this : data source
aws_iam_policy_document.secrets_management_assume  : data source
aws_iam_policy_document.secrets_assume_role_policy :  data source
aws_iam_policy_document.secrets_management   : data source
tls_certificate.cluster : data source
aws_iam_policy_document.ec2_assume_role : data source
aws_iam_policy_document.cluster_assume_role_policy  : data source
aws_iam_policy_document.alb_management  : data source
aws_iam_policy_document.cluster_elb_sl_role_creation  : data source


Inputs   : 

eks clsuter
    environment_id  : Environment ID for EKS clsuter deployment (e.g. dev)
    cluster_name    : Name of the EKS cluster 
    cluster_version : Kubernetes minor version to use for the EKS cluster (for example 1.21).
    iam_path        : If provided, all IAM roles will be created on this path.
    eks_subnet_ids  : A list of subnets to place the EKS cluster and workers within Subnet CIDR.
    eks_vpc_id      : VPC where the cluster and workers will be deployed.
    instance_types  : Worker Node EC2 instance type
    ssh_key         : EC2 Key Pair for worker nodes
    tags            : Tags to be applied to all resources created for the AWS resources
    desired_size    : The Size of the root EBS block device for worker node
    max_size        : Autoscaling Maximum node capacity
    min_size        : Autoscaling Minimum node capacity
    region          : The AWS Region to deploy EKS
    albc_namespace  : Kubernetes namespace to deploy the AWS ALB Controller into
    cluster_endpoint_private_access :  Indicates whether or not the Amazon EKS private API server endpoint is enabled.
    cluster_endpoint_public_access  : Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with cluster_endpoint_private_access = true
    disk_size       :  the Size of the root EBS block device for worker node
    permissions_boundary :  permissions boundary arn for IAM roles and policies 


Deployment :

You need to run the following commands to create the resources with Terraform:

terraform init
terraform plan
terraform apply

Cleaning up : 

You can destroy this cluster entirely by running:

terraform plan
terraform destroy


Authorize users to access the cluster : 

Initially, only the system that deployed the cluster will be able to access the cluster. To authorize other users for accessing the cluster, aws-auth config needs to be modified by using the steps given below:

    Open the aws-auth file in the edit mode on the machine that has been used to deploy EKS cluster:

command : kubectl edit -n kube-system configmap/aws-auth

    Add the following configuration in that file by changing the placeholders:

mapUsers: |
  - userarn: arn:aws:iam::111122223333:user/<username>
    username: <username>
    groups:
      - system:masters

So, the final configuration would look like this:

apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::555555555555:role/devel-worker-nodes-NodeInstanceRole-74RF4UBDUKL6
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::111122223333:user/<username>
      username: <username>
      groups:
        - system:masters

    Once the user map is added in the configuration we need to create cluster role binding for that user:

kubectl create clusterrolebinding ops-user-cluster-admin-binding-<username> --clusterrole=cluster-admin --user=<username>

Replace the placeholder with proper values


