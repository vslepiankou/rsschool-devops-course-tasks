# Provider configuration
provider "aws" {
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket         = "rs-school-vital-slepiankou-1"
    key            = "terraform/state"
    region         = "eu-central-1"
    profile        = "default"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rs-school-VPC"
    Source = "Terraform"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name   = "rs-school-GW"
    Source = "Terraform"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public subnet 1"
    Source = "Terraform"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public subnet 2"
    Source = "Terraform"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Private subnet 1"
    Source = "Terraform"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "Private subnet 2"
    Source = "Terraform"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name   = "Public RT"
    Source = "Terraform"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Default Private Route Table
resource "aws_default_route_table" "default_private_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    Name   = "Private RT"
    Source = "Terraform"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_default_route_table.default_private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_default_route_table.default_private_rt.id
}
