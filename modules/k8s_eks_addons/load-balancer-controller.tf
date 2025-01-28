locals {
  aws_load_balancer_controller_name            = "aws-load-balancer-controller"
  aws_load_balancer_controller_namespace       = "kube-system"
  aws_load_balancer_controller_service_account = "${local.aws_load_balancer_controller_name}-sa"
  amazon_container_image_registry_uris = {
    af-south-1     = "877085696533.dkr.ecr.af-south-1.amazonaws.com",
    ap-east-1      = "800184023465.dkr.ecr.ap-east-1.amazonaws.com",
    ap-northeast-1 = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com",
    ap-northeast-2 = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com",
    ap-northeast-3 = "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com",
    ap-south-1     = "602401143452.dkr.ecr.ap-south-1.amazonaws.com",
    ap-south-2     = "900889452093.dkr.ecr.ap-south-2.amazonaws.com",
    ap-southeast-1 = "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com",
    ap-southeast-2 = "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com",
    ap-southeast-3 = "296578399912.dkr.ecr.ap-southeast-3.amazonaws.com",
    ap-southeast-4 = "491585149902.dkr.ecr.ap-southeast-4.amazonaws.com",
    ca-central-1   = "602401143452.dkr.ecr.ca-central-1.amazonaws.com",
    cn-north-1     = "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn",
    cn-northwest-1 = "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn",
    eu-central-1   = "602401143452.dkr.ecr.eu-central-1.amazonaws.com",
    eu-central-2   = "900612956339.dkr.ecr.eu-central-2.amazonaws.com",
    eu-north-1     = "602401143452.dkr.ecr.eu-north-1.amazonaws.com",
    eu-south-1     = "590381155156.dkr.ecr.eu-south-1.amazonaws.com",
    eu-south-2     = "455263428931.dkr.ecr.eu-south-2.amazonaws.com",
    eu-west-1      = "602401143452.dkr.ecr.eu-west-1.amazonaws.com",
    eu-west-2      = "602401143452.dkr.ecr.eu-west-2.amazonaws.com",
    eu-west-3      = "602401143452.dkr.ecr.eu-west-3.amazonaws.com",
    me-south-1     = "558608220178.dkr.ecr.me-south-1.amazonaws.com",
    me-central-1   = "759879836304.dkr.ecr.me-central-1.amazonaws.com",
    sa-east-1      = "602401143452.dkr.ecr.sa-east-1.amazonaws.com",
    us-east-1      = "602401143452.dkr.ecr.us-east-1.amazonaws.com",
    us-east-2      = "602401143452.dkr.ecr.us-east-2.amazonaws.com",
    us-gov-east-1  = "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com",
    us-gov-west-1  = "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com",
    us-west-1      = "602401143452.dkr.ecr.us-west-1.amazonaws.com",
    us-west-2      = "602401143452.dkr.ecr.us-west-2.amazonaws.com"
  }
}

data "aws_iam_policy_document" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_config.enable ? 1 : 0

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeCoipPools",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:GetCoipPoolUsage",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:CreateSecurityGroup"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_context.partition_id}:ec2:*:*:security-group/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_context.partition_id}:ec2:*:*:security-group/*"]

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/ingress.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RemoveTags",
    ]

  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_context.partition_id}:ec2:*:*:security-group/*"]

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
    ]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteRule",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_context.partition_id}:elasticloadbalancing:*:*:targetgroup/*/*"]

    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:SetWebAcl",
    ]
  }
}


resource "aws_iam_policy" "aws_load_balancer_controller" {
  count       = var.aws_load_balancer_controller_config.enable ? 1 : 0
  name        = "${var.addon_context.eks_cluster_id}-aws-load-balancer-controller-irsa"
  description = "AWS Load Balancer Controller IAM policy"
  policy      = data.aws_iam_policy_document.aws_load_balancer_controller[0].json
  tags        = var.tags
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_config.enable ? 1 : 0
  metadata {
    name        = local.aws_load_balancer_controller_service_account
    namespace   = local.aws_load_balancer_controller_namespace
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.aws_load_balancer_controller[0].arn }
  }
  automount_service_account_token = true
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_config.enable ? 1 : 0

  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(local.aws_load_balancer_controller_service_account, "-*"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${local.aws_load_balancer_controller_service_account}."
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
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${local.aws_load_balancer_controller_namespace}:${local.aws_load_balancer_controller_service_account}",
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_config.enable ? 1 : 0

  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
  role       = aws_iam_role.aws_load_balancer_controller[0].name
}


resource "helm_release" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_config.enable ? 1 : 0

  name       = local.aws_load_balancer_controller_name
  namespace  = local.aws_load_balancer_controller_namespace
  repository = var.aws_load_balancer_controller_config.helm_repository
  chart      = local.aws_load_balancer_controller_name
  version    = var.aws_load_balancer_controller_config.helm_version
  timeout    = 1200
  values = [templatefile("${path.module}/templates/load_balancer_controller_values.yaml", {
    aws_region      = var.addon_context.aws_context.region_name
    eks_cluster_id  = var.addon_context.eks_cluster_id
    repository      = "${local.amazon_container_image_registry_uris[var.addon_context.aws_context.region_name]}/amazon/aws-load-balancer-controller"
    service_account = local.aws_load_balancer_controller_service_account
    }),
    var.aws_load_balancer_controller_config.chart_values
  ]
  description       = "AWS load balancer controller helm chart deployment configuration for ingress resources"
  dependency_update = true
}
