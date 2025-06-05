resource "aws_iam_role" "backup_iam_role" {
  count              = var.backup_service_enable ? 1 : 0
  name               = "${local.instance_identifier}-backup-role"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": ["sts:AssumeRole"],
        "Effect": "allow",
        "Principal": {
          "Service": ["backup.amazonaws.com"]
        }
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "service_backup" {
  count      = var.backup_service_enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_iam_role[0].name
}

resource "aws_iam_role_policy_attachment" "s3_backup" {
  count      = var.backup_service_enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.backup_iam_role[0].name
}

resource "aws_iam_role_policy_attachment" "restore" {
  count      = var.backup_service_enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_iam_role[0].name
}

resource "aws_iam_role_policy_attachment" "restore_s3" {
  count      = var.backup_service_enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.backup_iam_role[0].name
}

resource "aws_backup_vault" "backup_vault" {
  count = var.backup_service_enable ? 1 : 0
  name  = "${local.instance_identifier}-backup-vault"
}

resource "aws_backup_plan" "backup_plan" {
  count = var.backup_service_enable ? 1 : 0
  name  = "${local.instance_identifier}-backup-plan"

  rule {
    rule_name                = "${local.instance_identifier}-backup-rule"
    target_vault_name        = aws_backup_vault.backup_vault[0].name
    schedule                 = var.backup_schedule
    recovery_point_tags      = merge(var.tags, { "instance" : local.instance_identifier })
    enable_continuous_backup = true

    lifecycle {
      delete_after = var.backup_retention
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "ebs" {
  count        = var.backup_service_enable ? 1 : 0
  iam_role_arn = aws_iam_role.backup_iam_role[0].arn
  name         = "${local.instance_identifier}-ebs-selection"
  plan_id      = aws_backup_plan.backup_plan[0].id
  resources    = ["arn:aws:ec2:*:*:volume/*"]
  condition {
    string_equals {
      key   = "aws:ResourceTag/KubernetesCluster"
      value = var.eks_cluster_id
    }
    string_equals {
      key   = "aws:ResourceTag/kubernetes.io/created-for/pvc/name"
      value = "datadir-${var.ivs_release_name}-mongodb-0"
    }
    string_equals {
      key   = "aws:ResourceTag/kubernetes.io/created-for/pvc/namespace"
      value = var.k8s_namespace
    }
  }
}

resource "aws_backup_selection" "s3" {
  count        = var.backup_service_enable && (local.managed_buckets != []) ? 1 : 0
  iam_role_arn = aws_iam_role.backup_iam_role[0].arn
  name         = "${local.instance_identifier}-s3-selection"
  plan_id      = aws_backup_plan.backup_plan[0].id
  resources    = local.managed_buckets
}

resource "aws_s3_bucket_versioning" "data_bucket" {
  count  = var.backup_service_enable && var.data_bucket.create ? 1 : 0
  bucket = aws_s3_bucket.data_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "rawdata_bucket" {
  count  = var.backup_service_enable && var.raw_data_bucket.create ? 1 : 0
  bucket = aws_s3_bucket.rawdata_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
