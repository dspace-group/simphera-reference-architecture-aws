


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
