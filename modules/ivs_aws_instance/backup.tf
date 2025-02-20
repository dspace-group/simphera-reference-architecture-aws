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
      key   = "aws:ResourceTag/kubernetes.io/cluster/${var.infrastructurename}"
      value = "owned"
    }
    string_equals {
      key   = "aws:ResourceTag/kubernetes.io/created-for/pvc/name"
      value = "datadir-ivs-mongodb-0"
    }
  }
}

resource "aws_backup_selection" "s3" {
  count        = var.backup_service_enable ? 1 : 0
  iam_role_arn = aws_iam_role.backup_iam_role[0].arn
  name         = "${local.instance_identifier}-s3-selection"
  plan_id      = aws_backup_plan.backup_plan[0].id
  resources    = [aws_s3_bucket.data_bucket.arn, aws_s3_bucket.rawdata_bucket.arn]
}
