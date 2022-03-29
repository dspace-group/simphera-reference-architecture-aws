
locals {
  tenant              = var.tenant
  environment         = var.environment
  zone                = var.zone
  eks_cluster_id      = join("-", [local.tenant, local.environment, local.zone, "eks"])
  infrastructurename  = join("-", [local.tenant, local.environment, local.zone])
  zones               = length(data.aws_availability_zones.available.names)
  log_group_name      = "/${local.eks_cluster_id}/worker-fluentbit-logs"
  allowed_account_ids = [var.account_id]
}
