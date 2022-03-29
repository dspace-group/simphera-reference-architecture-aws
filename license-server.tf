

resource "aws_instance" "license_server" {
  count                = var.licenseServer ? 1 : 0
  ami                  = "ami-07df274a488ca9195" #Amazon Linux 2 AMI (HVM)    
  instance_type        = "t3a.large"
  iam_instance_profile = aws_iam_instance_profile.license_server_profile[0].name
  subnet_id            = module.vpc.private_subnets[0]
  tags                 = merge(var.tags, { "Name" = "${local.infrastructurename}-license-server" })
}
resource "aws_iam_role" "license_server_role" {
  count       = var.licenseServer ? 1 : 0
  description = "IAM role used for the license server instance profile."
  name        = "${local.infrastructurename}-role"
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
resource "aws_iam_role_policy" "role_policy" {
  count  = var.licenseServer ? 1 : 0
  name   = "${local.infrastructurename}-role-policy"
  role   = aws_iam_role.license_server_role[0].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${local.infrastructurename}-license-server"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::${local.infrastructurename}-license-server/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:UpdateInstanceInformation",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "license_server_bucket" {
  count  = var.licenseServer ? 1 : 0
  bucket = "${local.infrastructurename}-license-server"
  acl    = "private"
  tags   = var.tags
}
resource "aws_iam_instance_profile" "license_server_profile" {
  count = var.licenseServer ? 1 : 0
  name  = "${local.infrastructurename}-instance-profile"
  role  = aws_iam_role.license_server_role[0].name
}
