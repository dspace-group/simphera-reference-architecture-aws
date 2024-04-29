data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "preconfigured" {
  count = local.create_vpc ? 0 : 1
  id = var.vpcId
}

data "aws_subnets" "private_subnets" {
  count = local.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpcId]
  }

  tags = {
    purpose = "private"
  }
}

data "aws_subnet" "private_subnet" {
  for_each = local.create_vpc ? toset([]) : toset(data.aws_subnets.private_subnets[0].ids)
  id       = each.value
}

# Uncomment section below if you're using pre-configured public subnets
#data "aws_subnets" "public_subnets" {
#  count = local.create_vpc ? 0 : 1
#  filter {
#    name   = "vpc-id"
#    values = [var.vpcId]
#  }
#
#  tags = {
#    purpose = "public"
#  }
#}

#data "aws_subnet" "public_subnet" {
#  for_each = local.create_vpc ? toset([]) : toset(data.aws_subnets.public_subnets[0].ids)
#  id       = each.value
#}
