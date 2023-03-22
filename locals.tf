
locals {
  infrastructurename                        = var.infrastructurename
  zones                                     = length(data.aws_availability_zones.available.names)
  log_group_name                            = "/${module.eks.eks_cluster_id}/worker-fluentbit-logs"
  allowed_account_ids                       = [var.account_id]
  license_server_instance_id                = var.licenseServer ? split("instance/", aws_instance.license_server[0].arn)[1] : ""
  license_server_role                       = "${local.infrastructurename}-license-server-role"
  license_server_policy                     = "${local.infrastructurename}-license-server-policy"
  license_server_bucket                     = "${local.infrastructurename}-license-server-bucket"
  license_server                            = "${local.infrastructurename}-license-server"
  license_server_instance_profile           = "${local.infrastructurename}-license-server-instance-profile"
  flowlogs_cloudwatch_loggroup              = "/aws/vpc/${module.eks.eks_cluster_id}"
  patch_manager_cloudwatch_loggroup_scan    = "/aws/ssm/${module.eks.eks_cluster_id}/scan"
  patch_manager_cloudwatch_loggroup_install = "/aws/ssm/${module.eks.eks_cluster_id}/install"
  patchgroupid                              = "${var.infrastructurename}-patch-group"
}
