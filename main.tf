# Provider configuration
provider "aws" {
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket         = "rs-school-vital-slepiankou-1"
    key            = "terraform/state"
    region         = "eu-central-1"
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

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH from specific IPs for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

resource "aws_security_group" "general_ec2_sg" {
  name        = "general_ec2_sg"
  description = "Allow SSH and ICMP within VPC"
  vpc_id      = aws_vpc.main.id

  # Allow SSH within the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to match your VPC CIDR
  }

  # Allow ICMP within the VPC
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to match your VPC CIDR
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "General EC2 Security Group"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = "ami-0592c673f0b1e7665"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = "ssh"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id, aws_security_group.general_ec2_sg.id]

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_instance" "ec2_public_subnet_2" {
  ami                    = "ami-0592c673f0b1e7665"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.general_ec2_sg.id]
  key_name               = "ssh"

  tags = {
    Name = "EC2 in Public Subnet 2"
  }
}

resource "aws_instance" "ec2_private_subnet_1" {
  ami                    = "ami-0592c673f0b1e7665"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.general_ec2_sg.id]
  key_name               = "ssh"

  tags = {
    Name = "EC2 in Private Subnet 1"
  }
}

resource "aws_instance" "ec2_private_subnet_2" {
  ami                    = "ami-0592c673f0b1e7665"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.general_ec2_sg.id]
  key_name               = "ssh"

  tags = {
    Name = "EC2 in Private Subnet 2"
  }
}
