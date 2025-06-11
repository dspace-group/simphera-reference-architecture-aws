resource "aws_s3_bucket" "data_bucket" {
  count         = var.data_bucket.create ? 1 : 0
  bucket        = var.data_bucket.name
  tags          = var.tags
  force_destroy = var.enable_deletion_protection ? false : true
}

resource "aws_s3_bucket" "rawdata_bucket" {
  count         = var.raw_data_bucket.create ? 1 : 0
  bucket        = var.raw_data_bucket.name
  tags          = var.tags
  force_destroy = var.enable_deletion_protection ? false : true
}

resource "aws_iam_role_policy" "eks_node_s3_access_policy" {
  for_each = var.nodeRoleNames
  role     = each.value
  name     = "s3-access-policy"
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "${local.data_bucket_arn}",
                "${local.raw_data_bucket_arn}"
            ]
        },
        {
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${local.data_bucket_arn}/*",
                "${local.raw_data_bucket_arn}/*"
            ]
        },
        {
            "Action": [
                "s3:DeleteObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "${local.data_bucket_arn}/*",
                "${local.raw_data_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "s3_access" {
  name = "${local.ivs_buckets_service_account}-role"
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
            "${var.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.ivs_buckets_service_account}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "s3_access" {
  role   = aws_iam_role.s3_access.id
  name   = "${local.ivs_buckets_service_account}-access-policy"
  policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "s3:GetEncryptionConfiguration"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": [
                    "s3:ListBucket"
                ],
                "Effect": "Allow",
                "Resource": [
                    "${local.data_bucket_arn}",
                    "${local.raw_data_bucket_arn}"
                ]
            },
            {
                "Action": [
                    "s3:Get*",
                    "s3:List*",
                    "s3-object-lambda:Get*",
                    "s3-object-lambda:List*"
                ],
                "Effect": "Allow",
                "Resource": [
                    "${local.data_bucket_arn}/*",
                    "${local.raw_data_bucket_arn}/*"
                ]
            },
            {
                "Action": [
                    "s3:PutObject"
                ],
                "Effect": "Allow",
                "Resource": [
                    "${local.data_bucket_arn}/*",
                    "${local.raw_data_bucket_arn}/*"
                ]
            }
        ]
    }
    EOF
}

resource "kubernetes_service_account" "s3_access" {
  metadata {
    name      = local.ivs_buckets_service_account
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.s3_access.arn
    }
  }
  automount_service_account_token = false
}
