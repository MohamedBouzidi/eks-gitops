terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_range = toset([for idx in range(var.subnet_count) : tostring(idx)])
}

resource "aws_vpc" "main" {
  cidr_block                       = var.network_range
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.name}-main"
  }
}

resource "aws_subnet" "public" {
  for_each                = local.subnet_range
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.network_range, 4, each.key)
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name                                = "${var.name}-public-${each.key}"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
}

resource "aws_subnet" "private" {
  for_each          = local.subnet_range
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.network_range, 4, each.key + var.subnet_count)
  availability_zone = data.aws_availability_zones.available.names[each.key]

  tags = {
    Name                                = "${var.name}-private-${each.key}"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "shared"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.subnet_range
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eips" {
  for_each   = local.subnet_range
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name}-NAT-${each.key}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  for_each      = local.subnet_range
  allocation_id = aws_eip.nat_eips[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = local.subnet_range
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateways[each.key].id
  }

  tags = {
    Name = "${var.name}-private-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = local.subnet_range
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
