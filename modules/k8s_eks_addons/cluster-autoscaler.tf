locals {
  name            = "cluster-autoscaler"
  namespace       = "kube-system"
  service_account = "${local.name}-sa"
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.cluster_autoscaler_config.enable ? 1 : 0

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeInstanceTypes",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:autoscaling:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:autoScalingGroup:*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:eks:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:nodegroup/${var.addon_context.eks_cluster_id}/*"]

    actions = [
      "eks:DescribeNodegroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.cluster_autoscaler_config.enable ? 1 : 0
  name        = "${var.addon_context.eks_cluster_id}-cluster-autoscaler-irsa"
  description = "Cluster Autoscaler IAM policy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler[0].json

  tags = var.addon_context.tags
}

resource "helm_release" "cluster_autoscaler" {
  count      = var.cluster_autoscaler_config.enable ? 1 : 0
  name       = local.name
  namespace  = local.namespace
  repository = var.cluster_autoscaler_config.helm_repository
  chart      = local.name
  version    = var.cluster_autoscaler_config.helm_version
  timeout    = 1200
  values = [templatefile("${path.module}/templates/autoscaler_values.yaml", {
    aws_region      = var.addon_context.aws_region_name
    eks_cluster_id  = var.addon_context.eks_cluster_id
    image_tag       = "v${var.addon_context.eks_cluster_version}.0"
    service_account = local.service_account
    }),
    var.cluster_autoscaler_config.chart_values
  ]
  description       = "Cluster AutoScaler helm Chart deployment configuration."
  dependency_update = true


  dynamic "set" {
    iterator = each_item
    for_each = [
      {
        name  = "rbac.serviceAccount.create"
        value = "false"
      },
      {
        name  = "rbac.serviceAccount.name"
        value = local.service_account
      }
    ]

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = try(each_item.value.type, null)
    }
  }

  depends_on = [aws_iam_role.cluster_autoscaler]
}

resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  count = var.cluster_autoscaler_config.enable ? 1 : 0
  metadata {
    name        = local.service_account
    namespace   = local.namespace
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.cluster_autoscaler[0].arn }
  }

  automount_service_account_token = true
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.cluster_autoscaler_config.enable ? 1 : 0

  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(local.service_account, "-*"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${local.service_account}."
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
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${local.namespace}:${local.service_account}",
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  force_detach_policies = true

  tags = var.addon_context.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count = var.cluster_autoscaler_config.enable ? 1 : 0

  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
  role       = aws_iam_role.cluster_autoscaler[0].name
}
