# VPC
resource "aws_vpc" "vpc" {
  provider   = aws.account1
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.account1}-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "public" {
  provider          = aws.account1
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.account1}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "${var.account1}-igw"
  }
}

resource "aws_route_table" "public-rtb" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.account1}-public-rtb"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rtb.id
}