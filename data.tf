data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "preconfigured" {
  id = var.vpcId
}

data "aws_subnets" "private_subnets" {
  count    = var.vpcId == "" ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpcId]
  }

  tags = {
    purpose = "private"
  }
}

data "aws_subnets" "public_subnets" {
  count    = var.vpcId == "" ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpcId]
  }

  tags = {
    purpose = "public"
  }
}

data "aws_subnet" "private_subnet" {
  for_each = var.vpcId == "" ? toset([]) : toset(data.aws_subnets.private_subnets[0].ids)
  id       = each.value
}

data "aws_subnet" "public_subnet" {
  for_each = var.vpcId == "" ? toset([]) : toset(data.aws_subnets.public_subnets[0].ids)
  id       = each.value
}
