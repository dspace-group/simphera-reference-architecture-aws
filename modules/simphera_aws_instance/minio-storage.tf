resource "aws_iam_role" "minio_iam_role" {
  name        = "${local.instancename}-s3-role"
  description = "IAM role for the MinIO service account"
  tags        = var.tags
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.minio_serviceaccount}"
          }
        }
      }
    ]
  })

}

resource "aws_iam_policy" "minio_policy" {
  name        = "${local.instancename}-s3-policy"
  description = "Allows access to S3 bucket."
  policy      = templatefile("${path.module}/templates/minio-policy.json", { bucket = local.instancename })
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "minio_policy_attachment" {
  role       = aws_iam_role.minio_iam_role.name
  policy_arn = aws_iam_policy.minio_policy.arn
}

resource "kubernetes_service_account" "minio_service_account" {
  metadata {
    name      = local.minio_serviceaccount
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.minio_iam_role.arn
    }
  }
}
resource "aws_s3_bucket" "bucket" {
  bucket        = local.instancename
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

