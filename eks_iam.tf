############### EKS CLUSTER ROLE ###############

resource "aws_iam_role" "eks-cluster-role" {
  name                 = "eks-${var.cluster_name}-${var.environment_id}-cluster_role"
  permissions_boundary = var.permissions_boundary
  max_session_duration = 43200 # 12 hours
  path                 = var.iam_path_cluster


  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
	{
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": "ec"
            
        }
    
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "main-ekscluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "main-ekscluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "main-ekscluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "eks-${var.cluster_name}-${var.environment_id}-instance-profile"
  role = aws_iam_role.eks-cluster-role.name
  path = var.iam_path_cluster
}


############### EKS WORKER NODES ROLES ###############
## IAM role allowing Kubernetes actions to access other AWS services ##

resource "aws_iam_role" "node_group" {
  name                 = "eks-${var.cluster_name}-${var.environment_id}-node_group-role"
  permissions_boundary = var.permissions_boundary
  max_session_duration = 43200 # 12 hours
  path                 = var.iam_path_cluster

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "secrets_management_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-${var.cluster_name}-secrets-role"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "secrets_management_assume_policy" {
  name        = "${var.cluster_name}-secrets-management-assume-policy"
  description = "Permissions that are required to assume secrets role"
  policy      = data.aws_iam_policy_document.secrets_management_assume.json
  path        = var.iam_path_cluster
}

resource "aws_iam_role_policy_attachment" "node_group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "secrets_management_assume_policy_attachment" {
  policy_arn = aws_iam_policy.secrets_management_assume_policy.arn
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "main-ekscluster-secrets-assume-policy" {
  policy_arn = aws_iam_policy.secrets_management_assume_policy.arn
  role       = aws_iam_role.eks-cluster-role.name
}

################# ELB role for cluster #############
/*
 Adding a policy to cluster IAM role that allow permissions
 required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/

data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
   statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses",
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/*"]
  }
}

resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
  name = "${var.cluster_name}-elb-sl-role-creation"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation.json
  path        = var.albc_iam_path
  
}

resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation.arn
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_service_linked_role" "elasticloadbalancing" {
  aws_service_name = "elasticloadbalancing.amazonaws.com"
}
