# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.app_name}-${var.name}"
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create the public subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.app_name}-${var.public_subnet_name}-${count.index}",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create the private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 100}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.app_name}-${var.private_subnet_name}-${count.index}",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.app_name}-${var.name}-ig",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "${var.app_name}-${var.name}-public-rt",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an Elastic IP for the NAT gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.app_name}-${var.name}-ng-eip",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name        = "${var.app_name}-${var.name}-ng",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Create a route table for the private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name        = "${var.app_name}-${var.name}-private-rt",
    Environment = var.environment
    Version     = var.app_version
  }
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
