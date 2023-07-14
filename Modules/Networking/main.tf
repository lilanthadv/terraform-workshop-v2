/*======================================================================================================
  AWS VPC, Subnets (Public & Private), Internet Gateway, Nat Gateway and Route Table (Public & Private) 
========================================================================================================*/

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = var.vpc_name
      Description = var.vpc_description
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create the Public Subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.vpc_name}-public-subnet-${count.index}"
      Description = "${var.vpc_description}, Public Subnet ${count.index}"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create the Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 100}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.vpc_name}-private-subnet-${count.index}"
      Description = "${var.vpc_description}, Private Subnet ${count.index}"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create an Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.vpc_name}-ig"
      Description = "${var.vpc_description}, Internet Gateway"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create a Route Table for the Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(
    {
      Name        = "${var.vpc_name}-public-rt"
      Description = "${var.vpc_description}, Public Subnets Route Table"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Associate the Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = merge(
    {
      Name        = "${var.vpc_name}-ng-eip"
      Description = "${var.vpc_description}, NAT Gateway Elastic IP"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    {
      Name        = "${var.vpc_name}-ng"
      Description = "${var.vpc_description}, NAT gateway"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Create a Route Table for the Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(
    {
      Name        = "${var.vpc_name}-private-rt"
      Description = "${var.vpc_description}, Private Subnets Route Table"
      Owner       = split("/", data.aws_caller_identity.current_user.arn)[1]
      Terraform   = true
    },
    var.custom_tags != null ? var.custom_tags : {}
  )
}

# Associate the Private Subnets with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
