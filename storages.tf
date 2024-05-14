locals {
  storage_subnets = var.vpcId == "" ? { for index, zone in var.vpcPrivateSubnets : "zone${index}" => module.vpc[0].private_subnets[index] } : ( local.use_private_subnets_ids ? { for s, t in var.private_subnet_ids : "zone-${s}" => var.private_subnet_ids[s] } : { for s, t in data.aws_subnet.private_subnet : "zone-${s}" => data.aws_subnet.private_subnet[s].id } )
}

resource "aws_efs_file_system" "efs_file_system" {
  encrypted = true
  tags      = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "EfsPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:TagResource",
    ]

    resources = [aws_efs_file_system.efs_file_system.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_file_system.id
  policy         = data.aws_iam_policy_document.policy.json
}

resource "aws_efs_mount_target" "mount_target" {
  for_each        = local.storage_subnets
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = each.value
  security_groups = [module.eks.cluster_primary_security_group_id]
}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = aws_efs_file_system.efs_file_system.id
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks-addons
  ]
}
