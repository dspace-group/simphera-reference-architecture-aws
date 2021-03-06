

module "eks" {
  source             = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.0.4"
  tenant             = local.tenant
  environment        = local.environment
  zone               = local.zone
  cluster_version    = var.kubernetesVersion
  cluster_name       = var.infrastructurename
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  create_eks         = true
  map_accounts       = var.map_accounts
  map_users          = var.map_users
  map_roles          = var.map_roles
  tags               = var.tags
  managed_node_groups = {
    "default" = {
      node_group_name = "default"
      instance_types  = [var.linuxNodeSize]
      subnet_ids      = module.vpc.private_subnets
      desired_size    = var.linuxNodeCountMin
      max_size        = var.linuxNodeCountMax
      min_size        = var.linuxNodeCountMin
    },
    "execnodes" = {
      node_group_name = "execnodes"
      instance_types  = [var.linuxExecutionNodeSize]
      subnet_ids      = module.vpc.private_subnets
      desired_size    = var.linuxExecutionNodeCountMin
      max_size        = var.linuxExecutionNodeCountMax
      min_size        = var.linuxExecutionNodeCountMin
      k8s_labels = {
        "purpose" = "execution"
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
}


module "eks-addons" {
  source                              = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons?ref=v4.0.4"
  eks_cluster_id                      = module.eks.eks_cluster_id
  enable_amazon_eks_vpc_cni           = true
  enable_amazon_eks_coredns           = true
  enable_amazon_eks_kube_proxy        = true
  enable_aws_load_balancer_controller = false
  enable_cluster_autoscaler           = true
  enable_aws_for_fluentbit            = var.enable_aws_for_fluentbit
  enable_ingress_nginx                = var.enable_ingress_nginx
  tags                                = var.tags
  aws_for_fluentbit_helm_config = {
    values = [templatefile("${path.module}/templates/fluentbit_values.yaml", {
      aws_region           = data.aws_region.current.name,
      log_group_name       = local.log_group_name,
      service_account_name = "aws-for-fluent-bit-sa"
    })]
  }

  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/templates/nginx_values.yaml", {
      internal = "false",
      scheme   = "internet-facing",
    })]
  }
  cluster_autoscaler_helm_config = {
    values = [templatefile("${path.module}/templates/autoscaler_values.yaml", {
      aws_region           = data.aws_region.current.name,
      eks_cluster_id       = module.eks.eks_cluster_id,
      service_account_name = "cluster-autoscaler-sa"
    })]
  }
  depends_on = [module.eks.managed_node_groups]
}

