locals {
  route53_zone = "CHANGE"
}
# data "aws_route53_zone" "primary" {
#   count = var.ingress_nginx_config.enable ? 1 : 0
#   name  = local.route53_zone
# }

# data "aws_alb" "nginx" {
#   count = var.ingress_nginx_config.enable ? 1 : 0
#   tags = {
#     "kubernetes.io/service-name"                      = "nginx/ingress-nginx-controller"
#     "kubernetes.io/cluster/${var.infrastructurename}" = "owned"
#   }
#   depends_on = [module.k8s_eks_addons.helm_release]
# }

# resource "aws_route53_record" "simphera" {
#   count   = var.ingress_nginx_config.enable ? 1 : 0
#   zone_id = data.aws_route53_zone.primary[0].zone_id
#   name    = "vr-simphera.cws.dspace-dev.com"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [data.aws_alb.nginx[0].dns_name]
# }

# resource "aws_route53_record" "minio" {
#   count   = var.ingress_nginx_config.enable ? 1 : 0
#   zone_id = data.aws_route53_zone.primary[0].zone_id
#   name    = "vr-minio.cws.dspace-dev.com"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [data.aws_alb.nginx[0].dns_name]
# }

# resource "aws_route53_record" "keycloak" {
#   count   = var.ingress_nginx_config.enable ? 1 : 0
#   zone_id = data.aws_route53_zone.primary[0].zone_id
#   name    = "vr-keycloak.cws.dspace-dev.com"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [data.aws_alb.nginx[0].dns_name]
# }
