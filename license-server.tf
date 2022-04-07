

resource "aws_instance" "license_server" {
  count                = var.licenseServer ? 1 : 0
  ami                  = "ami-07df274a488ca9195" #Amazon Linux 2 AMI (HVM)    
  instance_type        = "t3a.large"
  iam_instance_profile = aws_iam_instance_profile.license_server_profile[0].name
  subnet_id            = module.vpc.private_subnets[0]
  tags                 = merge(var.tags, { "Name" = local.license_server })
}
resource "aws_iam_role" "license_server_role" {
  count       = var.licenseServer ? 1 : 0
  description = "IAM role used for the license server instance profile."
  name        = local.license_server_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "license_server_policy" {
  count       = var.licenseServer ? 1 : 0
  name        = local.license_server_policy
  description = "Allows access to S3 bucket and Secure Session Manager connections."
  policy      = templatefile("${path.module}/templates/license_server_policy.json", { bucket = local.license_server_bucket })
}

resource "aws_iam_role_policy_attachment" "minio_policy_attachment" {
  count      = var.licenseServer ? 1 : 0
  role       = aws_iam_role.license_server_role[0].name
  policy_arn = aws_iam_policy.license_server_policy[0].arn
}


resource "aws_s3_bucket" "license_server_bucket" {
  count  = var.licenseServer ? 1 : 0
  bucket = local.license_server_bucket
  acl    = "private"
}
resource "aws_iam_instance_profile" "license_server_profile" {
  count = var.licenseServer ? 1 : 0
  name  = local.license_server_instance_profile
  role  = aws_iam_role.license_server_role[0].name
}
