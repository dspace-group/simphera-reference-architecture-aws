module "simphera_instance" {
  source                       = "./modules/simphera_aws_instance"
  for_each                     = var.simpheraInstances
  region                       = local.region
  infrastructurename           = local.infrastructurename
  tags                         = var.tags
  eks_oidc_issuer_url          = module.eks.eks_oidc_issuer_url
  eks_oidc_provider_arn        = module.eks.eks_oidc_provider_arn
  name                         = each.value.name
  postgresqlApplyImmediately   = each.value.postgresqlApplyImmediately
  postgresqlVersion            = each.value.postgresqlVersion
  postgresqlStorage            = each.value.postgresqlStorage
  postgresqlMaxStorage         = each.value.postgresqlMaxStorage
  enableKeycloak               = each.value.enable_keycloak
  postgresqlStorageKeycloak    = each.value.postgresqlStorageKeycloak
  postgresqlMaxStorageKeycloak = each.value.postgresqlMaxStorageKeycloak
  db_instance_type_keycloak    = each.value.db_instance_type_keycloak
  db_instance_type_simphera    = each.value.db_instance_type_simphera
  k8s_namespace                = each.value.k8s_namespace
  secretname                   = each.value.secretname
  enable_backup_service        = each.value.enable_backup_service
  backup_retention             = each.value.backup_retention
  cloudwatch_retention         = var.cloudwatch_retention
  enable_deletion_protection   = each.value.enable_deletion_protection
  postgresql_security_group_id = module.security_group.security_group_id
  kms_key_cloudwatch           = aws_kms_key.kms_key_cloudwatch_log_group.arn
  log_bucket                   = aws_s3_bucket.bucket_logs.id
  private_subnets              = local.private_subnets

  depends_on = [module.eks, kubernetes_storage_class_v1.efs]
}
