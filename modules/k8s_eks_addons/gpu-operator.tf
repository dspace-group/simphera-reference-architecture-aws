resource "helm_release" "gpu_operator" {
  count = var.gpu_operator_config.enable ? 1 : 0

  namespace         = "kube-system"
  name              = "gpu-operator"
  chart             = "gpu-operator"
  create_namespace  = true
  repository        = var.gpu_operator_config.helm_repository
  version           = var.gpu_operator_config.helm_version
  description       = "The GPU operator HelmChart deployment configuration"
  dependency_update = true
  values = [
    var.gpu_operator_config.chart_values
  ]
  timeout = 1200
  wait    = false
  set {
    name  = "driver.version"
    value = var.gpu_operator_config.driver_version
  }
}
