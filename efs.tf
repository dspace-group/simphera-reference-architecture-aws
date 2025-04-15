resource "aws_efs_file_system" "efs_file_system" {
  count     = local.create_efs
  encrypted = true
  tags      = var.tags
}

data "aws_iam_policy_document" "policy" {
  count = local.create_efs
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

    resources = [aws_efs_file_system.efs_file_system[0].arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  count          = local.create_efs
  file_system_id = aws_efs_file_system.efs_file_system[0].id
  policy         = data.aws_iam_policy_document.policy[0].json
}

resource "aws_efs_mount_target" "mount_target" {
  for_each        = local.storage_subnets
  file_system_id  = aws_efs_file_system.efs_file_system[0].id
  subnet_id       = each.value
  security_groups = [module.eks.cluster_primary_security_group_id]
}

resource "kubernetes_storage_class_v1" "efs" {
  count = local.create_efs
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = aws_efs_file_system.efs_file_system[0].id
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.k8s_eks_addons
  ]
}
