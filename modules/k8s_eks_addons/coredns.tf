locals {
  coredns_addon_name = "coredns"
}

# resource "time_sleep" "coredns" {
#   count           = var.coredns_config.enable ? 1 : 0
#   create_duration = "1m"

#   triggers = {
#     eks_cluster_id = var.addon_context.eks_cluster_id
#   }
# }

data "aws_eks_addon_version" "coredns" {
  count              = var.coredns_config.enable ? 1 : 0
  addon_name         = local.coredns_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

data "aws_eks_cluster_auth" "coredns" {
  name = var.addon_context.eks_cluster_id
}

resource "aws_eks_addon" "coredns" {
  count = var.coredns_config.enable ? 1 : 0

  cluster_name      = var.addon_context.eks_cluster_id
  addon_name        = local.coredns_addon_name
  addon_version     = data.aws_eks_addon_version.coredns[0].version
  preserve          = true
  resolve_conflicts = "OVERWRITE"

  tags = merge(var.addon_context.tags)

}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = var.addon_context.eks_cluster_id
      cluster = {
        server = var.addon_context.eks_cluster_endpoint
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
        token = data.aws_eks_cluster_auth.coredns.token
      }
    }]
  })
}
resource "null_resource" "add_hosts_to_corefile" {
  depends_on = [aws_eks_addon.coredns]
  triggers   = {}
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-File"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    command = <<-EOT
      ${path.module}/scipts/update_corefile.ps1 -cluster ${var.addon_context.eks_cluster_id} -simphera_fqdn a.b.c.d -kubeconfig <(echo $KUBECONFIG | base64 -d)
    EOT
  }
}
