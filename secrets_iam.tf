data "aws_iam_policy_document" "secrets_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:AssumeRole"]
    effect  = "Allow"
    condition {
      test     = "StringLike"
      variable = "${replace(data.aws_eks_cluster.main_ekscluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:*"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "${replace(data.aws_eks_cluster.main_ekscluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main_ekscluster.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}
resource "aws_iam_role" "external-secrets-role" {
  name                 = "eks-${var.cluster_name}-secrets-role"
  description          = "Permissions required by the Kubernetes external secrets."
  permissions_boundary = var.permissions_boundary
  max_session_duration = 43200 # 12 hours
  assume_role_policy   = var.k8s_cluster_type == "vanilla" ? data.aws_iam_policy_document.ec2_assume_role.json : data.aws_iam_policy_document.secrets_assume_role_policy.json
}

data "aws_iam_policy_document" "secrets_management" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = ["arn:aws:secretsmanager:ap-southeast-2:${data.aws_caller_identity.current.account_id}:secret:*"]
    effect    = "Allow"
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]

    resources = ["arn:aws:ssm:ap-southeast-2:${data.aws_caller_identity.current.account_id}:parameter/*"]
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:AssumeRoleWithWebIdentity"
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-${var.cluster_name}-secrets-role"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "secrets_management_policy" {
  name        = "${var.cluster_name}-secrets-management-policy"
  description = "Permissions that are required to manage secrets."
  path        = var.albc_iam_path
  policy      = data.aws_iam_policy_document.secrets_management.json
}

resource "aws_iam_role_policy_attachment" "secrets_management_policy_attachment" {
  policy_arn = aws_iam_policy.secrets_management_policy.arn
  role       = aws_iam_role.external-secrets-role.name
}
