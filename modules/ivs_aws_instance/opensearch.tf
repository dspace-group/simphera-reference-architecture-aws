resource "aws_opensearch_domain" "opensearch" {
  count          = var.opensearch.enable ? 1 : 0
  domain_name    = var.opensearch.domain_name
  engine_version = var.opensearch.engine_version
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = local.master_user_secret["master_user"]
      master_user_password = local.master_user_secret["master_password"]
    }
  }
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
  cluster_config {
    instance_count         = var.opensearch.instance_count
    instance_type          = var.opensearch.instance_type
    zone_awareness_enabled = var.opensearch.instance_count > 1 ? true : false
    dynamic "zone_awareness_config" {
      for_each = var.opensearch.instance_count > 1 ? [1] : []
      content {
        availability_zone_count = var.opensearch.instance_count < 3 ? var.opensearch.instance_count : 3
      }
    }
  }
  ebs_options { # this is used if instance_type supports ebs storage, most of instance types do https://aws.amazon.com/opensearch-service/pricing/
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = "100" #?
    iops        = 3000
    throughput  = 125
  }
  vpc_options {
    subnet_ids = slice(var.opensearch.subnet_ids, 0, var.opensearch.instance_count < 3 ? var.opensearch.instance_count : 3)

    security_group_ids = var.opensearch.security_group_ids
  }
  access_policies = data.aws_iam_policy_document.opensearch_access[0].json
  tags            = var.tags
}
