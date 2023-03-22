resource "aws_backup_vault" "backup-vault" {
  count = var.enable_backup_service ? 1 : 0
  name  = local.backup_vault_name
}

resource "aws_backup_plan" "backup-plan" {
  count = var.enable_backup_service ? 1 : 0
  name  = "${local.instancename}-backup-plan"

  rule {
    rule_name                = "${local.instancename}-backup-rule"
    target_vault_name        = aws_backup_vault.backup-vault[0].name
    recovery_point_tags      = var.tags
    enable_continuous_backup = true

    lifecycle {
      delete_after = var.backup_retention
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "backup-selection-rds-s3" {
  count        = var.enable_backup_service ? 1 : 0
  name         = "${local.instancename}-rds-s3"
  iam_role_arn = aws_iam_role.backup_iam_role[0].arn
  plan_id      = aws_backup_plan.backup-plan[0].id
  resources    = local.backup_resources
}

resource "aws_iam_role" "backup_iam_role" {
  count              = var.enable_backup_service ? 1 : 0
  name               = "${var.name}-backup-role"
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

resource "aws_iam_role_policy_attachment" "backup_rds_policy" {
  count      = var.enable_backup_service ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_iam_role[0].name
}

resource "aws_iam_role_policy_attachment" "backup_s3_policy" {
  count      = var.enable_backup_service ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.backup_iam_role[0].name
}

