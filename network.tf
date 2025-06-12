module "vpc" {
  count                = local.create_vpc ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  version              = "v5.8.1"
  name                 = "${local.infrastructurename}-vpc"
  cidr                 = var.vpcCidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.vpcPrivateSubnets
  public_subnets       = var.vpcPublicSubnets
  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true
  tags                 = var.tags
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.infrastructurename}" = "shared"
    "kubernetes.io/role/elb"                            = "1"
    "purpose"                                           = "public"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.infrastructurename}" = "shared"
    "kubernetes.io/role/internal-elb"                   = "1"
    "purpose"                                           = "private"
  }
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "${var.infrastructurename}-db-sg"
  description = "PostgreSQL security group"
  vpc_id      = local.vpc_id
  tags        = var.tags
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = local.create_vpc ? module.vpc[0].vpc_cidr_block : data.aws_vpc.preconfigured[0].cidr_block
    },
  ]
}

# [EC2.6] VPC flow logging should be enabled in all VPCs
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-6
resource "aws_flow_log" "flowlog" {
  count           = local.create_vpc ? 1 : 0
  iam_role_arn    = aws_iam_role.flowlogs_role[0].arn
  log_destination = aws_cloudwatch_log_group.flowlogs[0].arn
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id
  tags            = var.tags
}

resource "aws_cloudwatch_log_group" "flowlogs" {
  count             = local.create_vpc ? 1 : 0
  name              = local.flowlogs_cloudwatch_loggroup
  retention_in_days = var.cloudwatch_retention
  kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  tags              = var.tags
}

resource "aws_iam_role" "flowlogs_role" {
  count              = local.create_vpc ? 1 : 0
  name               = "${local.infrastructurename}-flowlogs-role"
  description        = "AWS IAM service role for VPC flow logs."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_policy" "flowlogs_policy" {
  count  = local.create_vpc ? 1 : 0
  name   = "${local.infrastructurename}-flowlogs-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "flowlogs_attachment" {
  count      = local.create_vpc ? 1 : 0
  role       = aws_iam_role.flowlogs_role[0].id
  policy_arn = aws_iam_policy.flowlogs_policy[0].arn
}
