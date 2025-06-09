locals {
  master_user_secret          = var.opensearch.enable ? jsondecode(data.aws_secretsmanager_secret_version.opensearch_secret[0].secret_string) : null
  instance_identifier         = "${var.eks_cluster_id}-${var.instancename}-${var.k8s_namespace}"
  goofys_user_agent_name      = "aws:UserAgent\": \"aws-sdk-go/${var.goofys_user_agent_sdk_and_go_version["sdk_version"]} (go${var.goofys_user_agent_sdk_and_go_version["go_version"]}; linux; amd64)"
  ivs_buckets_service_account = "${local.instance_identifier}-sa"
  data_bucket_arn             = "arn:aws:s3:::${var.data_bucket.name}"
  raw_data_bucket_arn         = "arn:aws:s3:::${var.raw_data_bucket.name}"
  managed_buckets             = concat(var.data_bucket.create ? [local.data_bucket_arn] : [], var.raw_data_bucket.create ? [local.raw_data_bucket_arn] : [])
}
