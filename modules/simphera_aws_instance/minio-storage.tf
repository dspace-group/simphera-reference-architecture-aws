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

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "buckets_ssl" {

  bucket = aws_s3_bucket.bucket.bucket
  policy = templatefile("${path.module}/../../templates/bucket_policy.json", { bucket = aws_s3_bucket.bucket.bucket })
}

resource "aws_iam_policy" "minio_policy" {
  name        = "${local.instancename}-s3-policy"
  description = "Allows access to S3 bucket."
  policy      = templatefile("${path.module}/templates/minio-policy.json", { bucket = local.instancename })
  tags        = var.tags
}

resource "aws_iam_role" "executor_role" {
  name = "${var.name}-executoragentlinux"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:executoragentlinux"
          }
        }
      }
    ]
  })

  tags = var.tags

}
resource "aws_iam_role_policy_attachment" "minio_policy_attachment" {
  role       = aws_iam_role.minio_iam_role.name
  policy_arn = aws_iam_policy.minio_policy.arn
}

resource "aws_iam_role_policy_attachment" "executor_attachment" {
  role       = aws_iam_role.executor_role.name
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
  automount_service_account_token = false
}


resource "aws_s3_bucket" "bucket" {
  bucket = local.instancename
  tags   = var.tags
}


resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.bucket.id
  #[S3.9] S3 bucket server access logging should be enabled
  target_bucket = var.log_bucket
  target_prefix = "logs/bucket/${aws_s3_bucket.bucket.id}"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# [S3.4] S3 buckets should have server-side encryption enabled
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# [S3.8] S3 Block Public Access setting should be enabled at the bucket level
resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

