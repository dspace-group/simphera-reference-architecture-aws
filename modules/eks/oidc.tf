resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = distinct(compact(concat(["sts.${var.aws_context.partition_dns_suffix}"], [])))
  thumbprint_list = concat([data.tls_certificate.cluster_certificate.certificates[0].sha1_fingerprint], [])
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.cluster_name}-eks-irsa" },
    var.tags
  )
}
