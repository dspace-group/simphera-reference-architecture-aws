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
resource "aws_backup_vault" "backup-vault" {
  count = var.backup_service_enable ? 1 : 0
  name  = "${local.instance_identifier}-backup-vault"
}
