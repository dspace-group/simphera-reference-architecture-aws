resource "aws_s3_bucket" "bucket_logs" {
  bucket = "${var.infrastructurename}-logs"
  tags   = var.tags

  #[S3.9] S3 bucket server access logging should be enabled

}


resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.bucket_logs.id
  #[S3.9] S3 bucket server access logging should be enabled
  target_bucket = aws_s3_bucket.bucket_logs.id
  target_prefix = "logs/bucket/${aws_s3_bucket.bucket_logs.id}"
}

resource "aws_s3_bucket_public_access_block" "buckets_logs_access" {
  bucket                  = aws_s3_bucket.bucket_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "buckets_logs_ssl" {

  bucket = aws_s3_bucket.bucket_logs.bucket
  policy = templatefile("${path.module}/templates/bucket_policy.json", { bucket = aws_s3_bucket.bucket_logs.bucket })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_logs_encryption" {
  bucket = aws_s3_bucket.bucket_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_kms_key" "kms_key_cloudwatch_log_group" {
  description         = "KMS key used to encrypt Kubernetes, VPC Flow, Amazon RDS for PostgreSQL and SSM Patch manager log groups within infrastructure ${var.infrastructurename}"
  enable_key_rotation = true
  policy              = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${var.region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.region}:${var.account_id}:*"
                }
            }
        }    
    ]
}
POLICY
}
