resource "aws_vpc" "bedrock_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "project-bedrock-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.bedrock_vpc.id
  tags = {
    Name = "project-bedrock-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.bedrock_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "project-bedrock-public-1"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.bedrock_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "project-bedrock-public-2"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name                              = "project-bedrock-private-1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name                              = "project-bedrock-private-2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags = {
    Name = "project-bedrock-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bedrock_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "project-bedrock-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.bedrock_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "project-bedrock-private-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
