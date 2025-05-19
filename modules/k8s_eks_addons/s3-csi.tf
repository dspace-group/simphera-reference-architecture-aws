locals {
  aws_s3_csi_addon_name      = "aws-mountpoint-s3-csi-driver"
  aws_s3_csi_namespace       = "kube-system"
  aws_s3_csi_service_account = "s3-csi-driver-sa"
}

data "aws_eks_addon_version" "aws-mountpoint-s3-csi-driver" {
  count              = var.s3_csi_config.enable ? 1 : 0
  addon_name         = local.aws_s3_csi_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "aws-mountpoint-s3-csi-driver" {
  count                       = var.s3_csi_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.aws_s3_csi_addon_name
  addon_version               = data.aws_eks_addon_version.aws-mountpoint-s3-csi-driver[0].version
  service_account_role_arn    = aws_iam_role.s3_csi_driver_role[0].arn
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values        = var.coredns_config.configuration_values
  tags                        = var.tags
}

resource "aws_iam_role" "s3_csi_driver_role" {
  count       = var.s3_csi_config.enable ? 1 : 0
  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trimsuffix(local.aws_s3_csi_service_account, "-sa"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${local.aws_s3_csi_service_account}."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:${var.addon_context.aws_context.partition_id}:iam::${var.addon_context.aws_context.caller_identity_account_id}:oidc-provider/${var.addon_context.eks_oidc_issuer_url}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${local.aws_s3_csi_namespace}:${local.aws_s3_csi_service_account}",
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_policy" "Amazons3CSIDriverPolicy" {
  count       = var.s3_csi_config.enable ? 1 : 0
  name        = "${var.addon_context.eks_cluster_id}-s3-csi-driver-irsa"
  description = "Amazons3CSIDriverPolicy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MountpointFullBucketAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      },
      {
        "Sid" : "MountpointFullObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_csi_driver_policy_attachment" {
  count      = var.s3_csi_config.enable ? 1 : 0
  policy_arn = aws_iam_policy.Amazons3CSIDriverPolicy[0].arn
  role       = aws_iam_role.s3_csi_driver_role[0].name

  depends_on = [aws_iam_policy.Amazons3CSIDriverPolicy]
}
