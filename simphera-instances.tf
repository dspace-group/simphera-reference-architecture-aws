module "simphera_instance" {
  source                    = "./modules/simphera_aws_instance"
  for_each                  = var.simpheraInstances
  region                    = var.region
  infrastructurename        = local.infrastructurename
  k8s_cluster_id            = module.eks.eks_cluster_id
  k8s_cluster_oidc_arn      = module.eks.eks_oidc_provider_arn
  tags                      = var.tags
  eks_oidc_issuer_url       = module.eks.eks_oidc_issuer_url
  eks_oidc_provider_arn     = module.eks.eks_oidc_provider_arn
  name                      = each.value.name
  postgresqlVersion         = each.value.postgresqlVersion
  postgresqlStorage         = each.value.postgresqlStorage
  db_instance_type_keycloak = each.value.db_instance_type_keycloak
  db_instance_type_simphera = each.value.db_instance_type_simphera
  k8s_namespace             = each.value.k8s_namespace
  secretname                = each.value.secretname
  public_subnets            = module.vpc.public_subnets
  vpc_id                    = module.vpc.vpc_id
  depends_on = [
    module.eks,
    module.eks-addons
  ]
}
