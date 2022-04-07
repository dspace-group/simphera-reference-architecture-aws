
locals {
  tenant                          = var.tenant
  environment                     = var.environment
  zone                            = var.zone
  eks_cluster_id                  = join("-", [local.tenant, local.environment, local.zone, "eks"])
  infrastructurename              = join("-", [local.tenant, local.environment, local.zone])
  zones                           = length(data.aws_availability_zones.available.names)
  log_group_name                  = "/${local.eks_cluster_id}/worker-fluentbit-logs"
  allowed_account_ids             = [var.account_id]
  license_server_role             = "${local.infrastructurename}-license-server-role"
  license_server_policy           = "${local.infrastructurename}-license-server-policy"
  license_server_bucket           = "${local.infrastructurename}-license-server-bucket"
  license_server                  = "${local.infrastructurename}-license-server"
  license_server_instance_profile = "${local.infrastructurename}-license-server-instance-profile"
}
