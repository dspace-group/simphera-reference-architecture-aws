resource "aws_iam_role" "minio_iam_role" {
  name        = "${var.infrastructurename}-s3-role"
  description = "IAM role for the MinIO service account"
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
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.infrastructurename}-s3-policy"
  role = aws_iam_role.minio_iam_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:HeadBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.infrastructurename}",
          "arn:aws:s3:::${var.infrastructurename}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "*"
      }
    ]
  })
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
  bucket = var.infrastructurename
  acl    = "private"

}

