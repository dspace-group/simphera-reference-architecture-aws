resource "aws_efs_file_system" "measurement_fs" {
  creation_token = "mario-demo-simphera"
  encrypted      = true
  tags           = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "ExampleStatement01"
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

    resources = [aws_efs_file_system.measurement_fs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.measurement_fs.id
  policy         = data.aws_iam_policy_document.policy.json
}

resource "aws_efs_mount_target" "alpha" {
  for_each        = toset(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.measurement_fs.id
  subnet_id       = each.key
  security_groups = [module.eks.cluster_primary_security_group_id]
}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = aws_efs_file_system.measurement_fs.id
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks-addons
  ]
}
