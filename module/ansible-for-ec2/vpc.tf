# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "public" {
  availability_zone = var.public_subnet_az
  cidr_block        = var.public_subnet_cidr_block
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.app_name}-public-rtb"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rtb.id
}

# プライベートサブネット
resource "aws_subnet" "private" {
  availability_zone = var.private_subnet_az
  cidr_block        = var.private_subnet_cidr_block
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-public-subnet"
  }
}

# ルートテーブル
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-private-rtb"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rtb.id
}
