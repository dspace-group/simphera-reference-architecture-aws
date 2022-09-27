module "simphera_instance" {
  source                       = "./modules/simphera_aws_instance"
  for_each                     = var.simpheraInstances
  region                       = var.region
  infrastructurename           = local.infrastructurename
  k8s_cluster_id               = module.eks.eks_cluster_id
  k8s_cluster_oidc_arn         = module.eks.eks_oidc_provider_arn
  tags                         = var.tags
  eks_oidc_issuer_url          = module.eks.eks_oidc_issuer_url
  eks_oidc_provider_arn        = module.eks.eks_oidc_provider_arn
  name                         = each.value.name
  postgresqlVersion            = each.value.postgresqlVersion
  postgresqlStorage            = each.value.postgresqlStorage
  db_instance_type_keycloak    = each.value.db_instance_type_keycloak
  db_instance_type_simphera    = each.value.db_instance_type_simphera
  k8s_namespace                = each.value.k8s_namespace
  secretname                   = each.value.secretname
  public_subnets               = module.vpc.public_subnets
  vpc_id                       = module.vpc.vpc_id
  postgresql_security_group_id = module.security_group.security_group_id
}

output "simphera_db_instances" {
  value = tomap({
    for name, instance in module.simphera_instance : name => instance.simphera_db_instance
  })
  description = "Contains the address for the simphera database instance for a given SIMPHERA instance."
}

output "keycloak_db_instances" {
  value = tomap({
    for name, instance in module.simphera_instance : name => instance.keycloak_db_instance
  })
  description = "Contains the address for the keycloak database instance for a given SIMPHERA instance."
}
