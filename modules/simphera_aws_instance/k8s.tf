
resource "kubernetes_namespace" "k8s_namespace" {
  metadata {

    name = var.k8s_namespace
  }
}


resource "kubernetes_secret" "dockerconf" {
  count = local.create_pull_secret ? 1 : 0
  metadata {
    name      = "azure-docker-registry-credentials"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.simphera_chart_registry}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

}



resource "kubernetes_secret" "tls_certificate" {
  metadata {
    name      = "dspace-cloud-certificate"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
  }

  data = {
    "tls.crt" = file(var.secret_tls_public_file)
    "tls.key" = file(var.secret_tls_private_file)
  }

  type = "kubernetes.io/tls"
}
