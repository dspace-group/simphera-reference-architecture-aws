


module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "v3.11.0"
  name                 = "${local.infrastructurename}-vpc"
  cidr                 = var.vpcCidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.vpcPrivateSubnets
  public_subnets       = var.vpcPublicSubnets
  database_subnets     = var.vpcDatabaseSubnets
  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true
  tags                 = var.tags
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.infrastructurename}" = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.infrastructurename}" = "shared"
    "kubernetes.io/role/internal-elb"                   = "1"
  }
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "${var.infrastructurename}-db-sg"
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

# [EC2.6] VPC flow logging should be enabled in all VPCs
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-6
resource "aws_flow_log" "flowlog" {
  iam_role_arn    = aws_iam_role.flowlogs_role.arn
  log_destination = aws_cloudwatch_log_group.flowlogs.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}

resource "aws_cloudwatch_log_group" "flowlogs" {
  name              = local.flowlogs_cloudwatch_loggroup
  retention_in_days = var.cloudwatch_retention
  kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  tags              = var.tags
}

resource "aws_iam_role" "flowlogs_role" {
  name               = "${local.infrastructurename}-flowlogs-role"
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
}

resource "aws_iam_policy" "flowlogs_policy" {
  name   = "${local.infrastructurename}-flowlogs-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
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
}

resource "aws_iam_role_policy_attachment" "flowlogs_attachment" {
  role       = aws_iam_role.flowlogs_role.id
  policy_arn = aws_iam_policy.flowlogs_policy.arn
}
