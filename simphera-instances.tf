module "simphera_instance" {
  source                                = "./modules/simphera_aws_instance"
  for_each                              = var.simpheraInstances
  region                                = var.region
  infrastructurename                    = local.infrastructurename
  k8s_cluster_id                        = module.eks.eks_cluster_id
  k8s_cluster_oidc_arn                  = module.eks.eks_oidc_provider_arn
  tags                                  = var.tags
  dspaceEulaAccepted                    = var.dspaceEulaAccepted
  microsoftDotnetLibraryLicenseAccepted = var.microsoftDotnetLibraryLicenseAccepted
  eks_oidc_issuer_url                   = module.eks.eks_oidc_issuer_url
  eks_oidc_provider_arn                 = module.eks.eks_oidc_provider_arn
  name                                  = each.value.name
  postgresqlVersion                     = each.value.postgresqlVersion
  postgresqlStorage                     = each.value.postgresqlStorage
  db_instance_type_keycloak             = each.value.db_instance_type_keycloak
  db_instance_type_simphera             = each.value.db_instance_type_simphera
  k8s_namespace                         = each.value.k8s_namespace
  secretname                            = each.value.secretname
  secret_tls_public_file                = each.value.secret_tls_public_file
  secret_tls_private_file               = each.value.secret_tls_private_file
  simphera_fqdn                         = each.value.simphera_fqdn
  minio_fqdn                            = each.value.minio_fqdn
  keycloak_fqdn                         = each.value.keycloak_fqdn
  license_server_fqdn                   = each.value.license_server_fqdn
  public_subnets                        = module.vpc.public_subnets
  vpc_id                                = module.vpc.vpc_id
  simphera_chart_registry               = each.value.simphera_chart_registry
  simphera_chart_repository             = each.value.simphera_chart_repository
  simphera_chart_tag                    = each.value.simphera_chart_tag
  simphera_image_tag                    = each.value.simphera_image_tag
  registry_username                     = each.value.registry_username
  registry_password                     = each.value.registry_password
  simphera_chart_local_path             = each.value.simphera_chart_local_path
  depends_on = [
    module.eks,
    module.eks-addons
  ]
}
