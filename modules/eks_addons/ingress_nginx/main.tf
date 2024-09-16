locals {
  name      = try(var.helm_config.name, "ingress-nginx")
  namespace = try(var.helm_config.namespace, local.name)
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://kubernetes.github.io/ingress-nginx"
      version     = "4.1.4"
      namespace   = local.namespace
      description = "The NGINX HelmChart Ingress Controller deployment configuration"
    },
    var.helm_config
  )
}

resource "kubernetes_namespace_v1" "this" {
  count = try(var.helm_config.create_namespace, true) && local.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.namespace
  }
}

resource "helm_release" "ingress_nginx" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_config["name"]
  repository                 = try(local.helm_config["repository"], null)
  chart                      = local.helm_config["chart"]
  version                    = try(local.helm_config["version"], null)
  timeout                    = try(local.helm_config["timeout"], 1200)
  values                     = try(local.helm_config["values"], null)
  create_namespace           = try(local.helm_config["create_namespace"], false)
  namespace                  = local.helm_config["namespace"]
  lint                       = try(local.helm_config["lint"], false)
  description                = try(local.helm_config["description"], "")
  repository_key_file        = try(local.helm_config["repository_key_file"], "")
  repository_cert_file       = try(local.helm_config["repository_cert_file"], "")
  repository_username        = try(local.helm_config["repository_username"], "")
  repository_password        = try(local.helm_config["repository_password"], "")
  verify                     = try(local.helm_config["verify"], false)
  keyring                    = try(local.helm_config["keyring"], "")
  disable_webhooks           = try(local.helm_config["disable_webhooks"], false)
  reuse_values               = try(local.helm_config["reuse_values"], false)
  reset_values               = try(local.helm_config["reset_values"], false)
  force_update               = try(local.helm_config["force_update"], false)
  recreate_pods              = try(local.helm_config["recreate_pods"], false)
  cleanup_on_fail            = try(local.helm_config["cleanup_on_fail"], false)
  max_history                = try(local.helm_config["max_history"], 0)
  atomic                     = try(local.helm_config["atomic"], false)
  skip_crds                  = try(local.helm_config["skip_crds"], false)
  render_subchart_notes      = try(local.helm_config["render_subchart_notes"], true)
  disable_openapi_validation = try(local.helm_config["disable_openapi_validation"], false)
  wait                       = try(local.helm_config["wait"], true)
  wait_for_jobs              = try(local.helm_config["wait_for_jobs"], false)
  dependency_update          = try(local.helm_config["dependency_update"], false)
  replace                    = try(local.helm_config["replace"], false)

  postrender {
    binary_path = try(local.helm_config["postrender"], "")
  }

  dynamic "set" {
    iterator = each_item
    for_each = try(local.helm_config["set"], null) != null ? distinct(concat(var.set_values, local.helm_config["set"])) : var.set_values

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = try(each_item.value.type, null)
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = try(local.helm_config["set_sensitive"], null) != null ? concat(local.helm_config["set_sensitive"], var.set_sensitive_values) : var.set_sensitive_values

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = try(each_item.value.type, null)
    }
  }
}
