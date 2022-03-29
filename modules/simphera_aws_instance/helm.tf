resource "local_file" "charts_folder" {
  count    = local.install_from_local ? 0 : 1
  filename = "./charts/readme.md"
  content  = "This file only exists for initially creating the `charts` folder."
}

resource "local_file" "values" {
  filename = "./values.yaml"
  content  = templatefile("${path.module}/templates/quickstart.yaml", local.quickstart_helm_values)
}



resource "null_resource" "repo_login" {
  count = local.install_from_local || var.registry_username == "" || var.registry_password == "" ? 0 : 1
  provisioner "local-exec" {
    command = "helm registry login -u ${var.registry_username} -p ${var.registry_password} ${var.simphera_chart_registry}"
    environment = {
      HELM_EXPERIMENTAL_OCI = 1
    }
  }
  depends_on = [local_file.charts_folder]
}

resource "null_resource" "pull_chart" {
  count = local.install_from_local ? 0 : 1
  provisioner "local-exec" {
    command = "helm chart pull ${var.simphera_chart_registry}/${var.simphera_chart_repository}:${var.simphera_chart_tag}"
    environment = {
      HELM_EXPERIMENTAL_OCI = 1
    }
  }
  depends_on = [null_resource.repo_login]
}

resource "null_resource" "export_chart" {
  count = local.install_from_local ? 0 : 1
  provisioner "local-exec" {
    working_dir = "./charts"
    command     = "helm chart export ${var.simphera_chart_registry}/${var.simphera_chart_repository}:${var.simphera_chart_tag}"
    environment = {
      HELM_EXPERIMENTAL_OCI = 1
    }
  }
  depends_on = [null_resource.pull_chart]
}

resource "helm_release" "simphera" {
  name      = "simphera"
  chart     = local.simphera_chart_path
  version   = var.simphera_image_tag
  namespace = var.k8s_namespace
  #timeout   = "1200"
  wait   = false # TODO set to true for production
  values = [templatefile("${path.module}/templates/quickstart.yaml", local.quickstart_helm_values)]
  depends_on = [
    null_resource.export_chart
  ]
}
