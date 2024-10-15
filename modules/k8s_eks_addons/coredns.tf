locals {
  coredns_addon_name = "coredns"
}

data "aws_eks_addon_version" "coredns" {
  count              = var.coredns_config.enable ? 1 : 0
  addon_name         = local.coredns_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

data "aws_eks_cluster_auth" "coredns" {
  count = var.coredns_config.enable ? 1 : 0
  name  = var.addon_context.eks_cluster_id
}

resource "aws_eks_addon" "coredns" {
  count             = var.coredns_config.enable ? 1 : 0
  cluster_name      = var.addon_context.eks_cluster_id
  addon_name        = local.coredns_addon_name
  addon_version     = data.aws_eks_addon_version.coredns[0].version
  preserve          = true
  resolve_conflicts = "OVERWRITE"
  tags              = merge(var.addon_context.tags)

}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = var.addon_context.eks_cluster_id
      cluster = {
        certificate-authority-data = var.addon_context.cluster_certificate_authority_data
        server                     = var.addon_context.eks_cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = var.addon_context.eks_cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.coredns[0].token
      }
    }]
  })
}

resource "null_resource" "add_hosts_to_corefile" {
  count      = var.coredns_config.enable && var.coredns_config.add_corefile_hosts ? 1 : 0
  depends_on = [aws_eks_addon.coredns]
  triggers = {
    script_content = base64encode(file("${path.module}/scripts/update_corefile.ps1"))
    hosts          = join(", ", [for name in var.coredns_config.corefile_hosts : format("%q", name)])
  }
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
  ./${path.module}/scripts/update_corefile.ps1 `
    -cluster_name "${var.addon_context.eks_cluster_id}" `
    -simphera_fqdns ${null_resource.add_hosts_to_corefile[0].triggers.hosts} `
    -kubeconfig_encoded_content ${base64encode(local.kubeconfig)}
  EOT
  }
}
