data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.system}-${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.system}-${var.env}-igw"
  }
}

resource "aws_route" "int_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "public" {
  count             = length(var.cidr_public)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.cidr_public, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.system}-${var.env}-public${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.cidr_private)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.cidr_private, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.system}-${var.env}-private${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.system}-${var.env}-public-rtb"
  }
}
resource "aws_route_table_association" "public" {
  count          = length(var.cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count          = var.nat_gateway_create ? 0 : 1
  vpc_id         = aws_vpc.vpc.id
  tags = {
    Name = "${var.system}-${var.env}-private-rtb"
  }
}
resource "aws_route_table_association" "private" {
  count          = var.nat_gateway_create ? 0 : length(var.cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}

resource "aws_main_route_table_association" "private" {
  count          = var.nat_gateway_create ? 0 : 1
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_eip" "nat" {
  count = "${var.nat_gateways_count}"
  #vpc   = true
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count         = "${var.nat_gateways_count}"
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = {
    Name = "${var.system}-${var.env}-ngw${count.index + 1}"
  }
}

resource "aws_route_table" "nat_private" {
  count          = "${var.nat_gateways_count}"
  vpc_id         = aws_vpc.vpc.id
  tags = {
    Name = "${var.system}-${var.env}-private-rt-${count.index + 1}"
  }
}
resource "aws_route_table_association" "nat_private" {
  count          = "${var.nat_gateways_count}"
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.nat_private.*.id, count.index)
}

resource "aws_route" "nat_gateway" {
  count         = "${var.nat_gateways_count}"
  route_table_id         = element(aws_route_table.nat_private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
  
  depends_on             = [
    aws_route_table.nat_private
  ]
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = compact(
    flatten([
      aws_subnet.public.*.id,
      aws_subnet.private.*.id
    ])
  )
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "${var.system}-${var.env}-nacl"
  }
}
