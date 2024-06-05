resource "aws_instance" "license_server" {
  count                  = var.licenseServer ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_kernel5.id
  instance_type          = "t3a.large"
  iam_instance_profile   = aws_iam_instance_profile.license_server_profile[0].name
  subnet_id              = local.private_subnets[0]
  vpc_security_group_ids = [module.security_group_license_server[0].security_group_id]

  metadata_options {
    # [EC2.8] EC2 instances should use IMDSv2
    # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-8
    http_endpoint = "enabled"
    http_tokens   = "required" # Require session token for Instance Metadata Service Version 2 (IMDSv2)
  }
  user_data = <<-EOF
#!/bin/bash
yum update -y
wget -O CodeMeter.rpm "${var.codemeter}"
yum -y localinstall CodeMeter.rpm
systemctl stop codemeter
sed -i -e '/IsNetworkServer=/ s/=.*/=1/' /etc/wibu/CodeMeter/Server.ini
systemctl start codemeter
systemctl enable codemeter

if ${var.enable_ivs}; then 
  
  # Create a download folder
  mkdir ~/downloads
  cd ~/downloads

  echo "Downloading RTMaps"
  # Download RTMaps
  url='${var.rtMaps}'
  wget -q $url
                  
  filename=`echo $url | awk  -F / '{print $NF}'`
  echo "Extracting the files"
  # Extract the files
  tar -xf $filename

  # Create the folder and copy the license server
  mkdir -p /opt/rtmaps/license
  cp -a ~/downloads/rtmaps/license/rlm/ubuntu1804_x86_64/. /opt/rtmaps/license

  # Delete the rest
  rm -r ~/downloads

  echo "Create the rlm.service"
  # Create the rlm.service
  cat <<-EOF1 > /etc/systemd/system/rlm.service
  [Unit]
  Description=RLM license server for RTMaps
  After=syslog.target network.target

  [Service]
  Type=simple
  User=ec2-user
  ExecStart=/opt/rtmaps/license/rlm -dlog /opt/rtmaps/license/rlm.dl
  ExecStop=/opt/rtmaps/license/rlmutil rlmdown RLM -q

  [Install]
  WantedBy=default.target
EOF1

echo "Reload the services"
# Reload the services
systemctl daemon-reload

echo "Enable the rlm.service"
systemctl enable rlm.service
fi
EOF

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
  tags = merge(var.tags, { "Name" = local.license_server, "Patch Group" = local.patchgroupid })
}

data "aws_ami" "amazon_linux_kernel5" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-202*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
resource "aws_iam_role" "license_server_role" {
  count       = var.licenseServer ? 1 : 0
  description = "IAM role used for the license server instance profile."
  name        = local.license_server_role
  tags        = var.tags
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
  policy      = templatefile("${path.module}/templates/license_server_policy.json", { bucket = local.license_server_bucket_name })
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "minio_policy_attachment" {
  count      = var.licenseServer ? 1 : 0
  role       = aws_iam_role.license_server_role[0].name
  policy_arn = aws_iam_policy.license_server_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "license_server_ssm" {
  count      = var.licenseServer ? 1 : 0
  role       = aws_iam_role.license_server_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_s3_bucket" "license_server_bucket" {
  count  = var.licenseServer ? 1 : 0
  bucket = local.license_server_bucket_name
  tags   = var.tags
}

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "license_server_bucket_ssl" {
  count  = var.licenseServer ? 1 : 0
  bucket = aws_s3_bucket.license_server_bucket[0].id
  policy = templatefile("${path.module}/templates/bucket_policy.json", { bucket = aws_s3_bucket.license_server_bucket[0].id })
}

resource "aws_iam_instance_profile" "license_server_profile" {
  count = var.licenseServer ? 1 : 0
  name  = local.license_server_instance_profile
  role  = aws_iam_role.license_server_role[0].name
}

module "security_group_license_server" {
  count       = var.licenseServer ? 1 : 0
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "${var.infrastructurename}-license-server"
  description = "License server security group"
  vpc_id      = local.vpc_id
  tags        = var.tags
  ingress_with_source_security_group_id = [
    {
      type                     = "ingress"
      from_port                = 22350
      to_port                  = 22350
      protocol                 = "tcp"
      description              = "Inbound TCP on port 22350 from kubernetes nodes security group"
      source_security_group_id = module.eks.cluster_primary_security_group_id
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
