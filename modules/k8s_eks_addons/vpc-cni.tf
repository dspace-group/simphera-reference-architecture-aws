locals {
  aws_vpc_cni_addon_name      = "vpc-cni"
  aws_vpc_cni_service_account = "aws-node"
  aws_vpc_cni_namespace       = "kube-system"
}

data "aws_eks_addon_version" "aws_vpc_cni" {
  addon_name         = local.aws_vpc_cni_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "aws_vpc_cni" {
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.aws_vpc_cni_addon_name
  addon_version               = data.aws_eks_addon_version.aws_vpc_cni.version
  service_account_role_arn    = aws_iam_role.aws_vpc_cni_role.arn
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.addon_context.tags
}

resource "aws_iam_role" "aws_vpc_cni_role" {
  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trimsuffix(local.aws_vpc_cni_service_account, "-sa"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${local.aws_vpc_cni_service_account}."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:oidc-provider/${var.addon_context.eks_oidc_issuer_url}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${local.aws_vpc_cni_namespace}:${local.aws_vpc_cni_service_account}",
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  force_detach_policies = true

  tags = var.addon_context.tags
}

resource "aws_iam_role_policy_attachment" "aws_vpc_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws_vpc_cni_role.name
}
