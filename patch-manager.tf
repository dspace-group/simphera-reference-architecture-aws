resource "aws_ssm_maintenance_window" "scan" {
  count             = var.enable_patching ? 1 : 0
  name              = "scan-${var.infrastructurename}"
  cutoff            = 0
  description       = "Maintenance window for scanning for patch compliance"
  duration          = var.maintainance_duration
  schedule          = var.scan_schedule
  schedule_timezone = "UTC"
  tags              = var.tags
}

resource "aws_ssm_maintenance_window" "install" {
  count             = var.enable_patching ? 1 : 0
  name              = "install-${var.infrastructurename}"
  cutoff            = 0
  description       = "Maintenance window for applying patches"
  duration          = var.maintainance_duration
  schedule          = var.install_schedule
  schedule_timezone = "UTC"
  tags              = var.tags
}

resource "aws_ssm_maintenance_window_target" "scan" {
  count         = var.enable_patching ? 1 : 0
  window_id     = aws_ssm_maintenance_window.scan[0].id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:name"
    values = [local.eks_cluster_id]
  }
}

resource "aws_ssm_maintenance_window_target" "install" {
  count         = var.enable_patching && var.licenseServer ? 1 : 0
  window_id     = aws_ssm_maintenance_window.install[0].id
  resource_type = "INSTANCE"

  targets {
    key    = "InstanceIds"
    values = [local.license_server_instance_id]
  }
}

resource "aws_ssm_maintenance_window_task" "scan" {
  count           = var.enable_patching ? 1 : 0
  max_concurrency = 50
  max_errors      = 0
  priority        = 1
  task_type       = "RUN_COMMAND"
  task_arn        = "AWS-RunPatchBaseline"
  window_id       = aws_ssm_maintenance_window.scan[0].id
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.scan[0].id]
  }
  task_invocation_parameters {
    run_command_parameters {
      comment         = "Runs a compliance scan"
      timeout_seconds = 600

      cloudwatch_config {
        cloudwatch_log_group_name = aws_cloudwatch_log_group.ssm_scan_log_group.name
        cloudwatch_output_enabled = true
      }

      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
    }
  }
}


resource "aws_ssm_maintenance_window_task" "install" {
  count           = var.enable_patching && var.licenseServer ? 1 : 0
  max_concurrency = 50
  max_errors      = 0
  priority        = 1
  task_type       = "RUN_COMMAND"
  task_arn        = "AWS-RunPatchBaseline"
  window_id       = aws_ssm_maintenance_window.install[0].id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.install[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment         = "Installs necessary patches"
      timeout_seconds = 600

      cloudwatch_config {
        cloudwatch_log_group_name = aws_cloudwatch_log_group.ssm_install_log_group.name
        cloudwatch_output_enabled = true
      }
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "ssm_scan_log_group" {
  name              = local.patch_manager_cloudwatch_loggroup_scan
  retention_in_days = 30
  kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "ssm_install_log_group" {
  name              = local.patch_manager_cloudwatch_loggroup_install
  retention_in_days = 30
  kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  tags              = var.tags
}
