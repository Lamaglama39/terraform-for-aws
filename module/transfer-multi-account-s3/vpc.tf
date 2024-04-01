# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project}-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "public" {
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}

# ルートテーブル
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-public-rtb"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rtb.id
}

# # プライベートサブネット
# resource "aws_subnet" "private_1a" {
#   availability_zone = "ap-northeast-1a"
#   cidr_block        = "10.0.2.0/24"
#   vpc_id            = aws_vpc.vpc.id
#   tags = {
#     Name = "${var.project}-private-subnet-1a"
#   }
# }

# # ルートテーブル
# resource "aws_route_table" "private-rtb" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name = "${var.project}-private-rtb"
#   }
# }

# resource "aws_route_table_association" "public_association-1a" {
#   subnet_id      = aws_subnet.private_1a.id
#   route_table_id = aws_route_table.private-rtb.id
# }
