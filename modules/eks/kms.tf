# Create a KMS customer managed key
resource "aws_kms_key" "cluster" {
  description             = "${var.cluster_name} EKS cluster secret encryption key"
  policy                  = data.aws_iam_policy_document.eks_key.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = var.tags
}

# Assign an alias to the key
resource "aws_kms_alias" "cluster" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.cluster.key_id
}
