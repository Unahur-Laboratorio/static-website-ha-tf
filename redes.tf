resource "aws_vpc" "ha_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "ha-vpc" }
}

resource "aws_internet_gateway" "ha_igw" {
  vpc_id = aws_vpc.ha_vpc.id
  tags   = { Name = "ha-igw" }
}

resource "aws_subnet" "ha_public_subnet_a" {
  vpc_id                  = aws_vpc.ha_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "ha-public-subnet-a" }
}

resource "aws_subnet" "ha_public_subnet_b" {
  vpc_id                  = aws_vpc.ha_vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags                    = { Name = "ha-public-subnet-b" }
}

resource "aws_route_table" "ha_rt_public" {
  vpc_id = aws_vpc.ha_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ha_igw.id
  }
  tags = { Name = "ha-rt-public" }
}

resource "aws_route_table_association" "ha_rt_assoc_a" {
  subnet_id      = aws_subnet.ha_public_subnet_a.id
  route_table_id = aws_route_table.ha_rt_public.id
}

resource "aws_route_table_association" "ha_rt_assoc_b" {
  subnet_id      = aws_subnet.ha_public_subnet_b.id
  route_table_id = aws_route_table.ha_rt_public.id
}