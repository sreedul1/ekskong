
data "aws_iam_policy_document" "external_dns" {
    statement {
    sid    = "ChangeResourceRecordSets"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = formatlist(
      "arn:aws:route53:::hostedzone/%s",
       var.policy_allowed_zone_ids
    )
  }

  statement {
    sid    = "ListResourceRecordSets"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "external_policy_assume" {
  
  statement {
    sid    = "AllowAssumeExternalDNSRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.policy_assume_role_enabled
    ]
  }
}

data "aws_iam_policy_document" "external_dns_assume" {
  statement {    
    actions = [
      "sts:AssumeRoleWithWebIdentity",           
      ]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.main_ekscluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.external_dns_namespace}:${var.external_dns_service_account_name}"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main_ekscluster.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_policy" "external_dns" {
  
  name        = "${var.cluster_name}-external_dns"
  path        =  var.albc_iam_path
  description = "Policy for external-dns service"
  policy      =  var.policy_assume_role_enabled ? data.aws_iam_policy_document.external_policy_assume.json : data.aws_iam_policy_document.external_dns.json
  
}

resource "aws_iam_role" "external_dns" {
  name               = "${var.cluster_name}-external-dns"
  path        = var.albc_iam_path
  force_detach_policies = true
  permissions_boundary  = var.permissions_boundary
  max_session_duration  = 43200 # 12 hours
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
