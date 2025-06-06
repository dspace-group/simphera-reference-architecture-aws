locals {
  gpu_driver_versions_escaped = { for driver in var.gpu_operator_config.driver_versions : driver => replace(driver, ".", "-") if var.gpu_operator_config.enable }
}


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
}

# kubernetes_manifest from hashicorp/kubernetes provider doesnt work with custom resources yet,
# see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775 for more information
resource "kubectl_manifest" "nvidia-driver" {
  for_each = local.gpu_driver_versions_escaped

  yaml_body = <<YAML
apiVersion: nvidia.com/v1alpha1
kind: NVIDIADriver
metadata:
  name: driver-gpu-nodes-${each.value}
spec:
  driverType: gpu
  image: driver
  repository: nvcr.io/nvidia
  nodeSelector:
    gpu-driver: ${each.key}
  tolerations:
  - key: purpose
    operator: Equal
    value: gpu
    effect: NoSchedule
  - key: nvidia.com/gpu
    value: ""
    operator: Exists
    effect: NoSchedule
  version: ${each.key}
YAML

  depends_on = [helm_release.gpu_operator]
}
