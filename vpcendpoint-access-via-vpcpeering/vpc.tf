##############################################################################################
# 接続元VPC (アカウントA)
##############################################################################################

## VPC
resource "aws_vpc" "vpc_a" {
  provider             = aws.account1
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr_1
  tags = {
    Name = "${var.account1}-vpc-1"
  }
}

## パブリックサブネット
resource "aws_subnet" "public_subnet_a" {
  provider          = aws.account1
  availability_zone = "ap-northeast-1a"
  cidr_block        = var.subnet_cidr_public_1
  vpc_id            = aws_vpc.vpc_a.id
  tags = {
    Name = "${var.account1}-public-subnet-1"
  }
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "igw_a" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc_a.id
  tags = {
    Name = "${var.account1}-igw-1"
  }
}

## ルーティングテーブル
resource "aws_route_table" "public_rtb_a" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc_a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }
  route {
    cidr_block                = aws_vpc.vpc_b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "${var.account1}-public-rtb-1"
  }
}

## ルーティングテーブル設定
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rtb_a.id
}

##############################################################################################
# VPCエンドポイント用VPC (アカウントA)
##############################################################################################

## VPC
resource "aws_vpc" "vpc_b" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  provider             = aws.account1
  cidr_block           = var.vpc_cidr_2
  tags = {
    Name = "${var.account1}-vpc-2"
  }
}

## プライベートサブネット
resource "aws_subnet" "private_subnet_b" {
  provider          = aws.account1
  availability_zone = "ap-northeast-1a"
  cidr_block        = var.subnet_cidr_private_2
  vpc_id            = aws_vpc.vpc_b.id
  tags = {
    Name = "${var.account1}-private-subnet-2"
  }
}

## パブリックサブネット
resource "aws_subnet" "public_subnet_b" {
  provider          = aws.account1
  availability_zone = "ap-northeast-1a"
  cidr_block        = var.subnet_cidr_public_2
  vpc_id            = aws_vpc.vpc_b.id
  tags = {
    Name = "${var.account1}-public-subnet-2"
  }
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "igw_b" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc_b.id
  tags = {
    Name = "${var.account1}-igw-2"
  }
}

## プライベート ルーティングテーブル
resource "aws_route_table" "private_rtb_b" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc_b.id
  route {
    cidr_block                = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "${var.account1}-private-rtb-2"
  }
}

## パブリック ルーティングテーブル
resource "aws_route_table" "public_rtb_b" {
  provider = aws.account1
  vpc_id   = aws_vpc.vpc_b.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }

  tags = {
    Name = "${var.account1}-public-rtb-2"
  }
}

## プライベート ルーティングテーブル設定
resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rtb_b.id
}

## パブリック ルーティングテーブル設定
resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rtb_b.id
}


##############################################################################################
# VPCピアリング (アカウントA)
##############################################################################################
resource "aws_vpc_peering_connection" "vpc_peering" {
  provider    = aws.account1
  peer_vpc_id = aws_vpc.vpc_a.id
  vpc_id      = aws_vpc.vpc_b.id
  auto_accept = true

  tags = {
    Name = "${var.account1}-vpc-peering-1"
  }
}


##############################################################################################
# 接続先VPC (アカウントB)
##############################################################################################

## VPC
resource "aws_vpc" "vpc_c" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  provider             = aws.account2
  cidr_block           = var.vpc_cidr_3
  tags = {
    Name = "${var.account2}-vpc-3"
  }
}

## プライベートサブネット
resource "aws_subnet" "private_subnet_c" {
  provider          = aws.account2
  availability_zone = "ap-northeast-1a"
  cidr_block        = var.subnet_cidr_private_3
  vpc_id            = aws_vpc.vpc_c.id
  tags = {
    Name = "${var.account2}-private-subnet-3"
  }
}

## パブリックサブネット
resource "aws_subnet" "public_subnet_c" {
  provider          = aws.account2
  availability_zone = "ap-northeast-1a"
  cidr_block        = var.subnet_cidr_public_3
  vpc_id            = aws_vpc.vpc_c.id
  tags = {
    Name = "${var.account2}-public-subnet-3"
  }
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "igw_c" {
  provider = aws.account2
  vpc_id   = aws_vpc.vpc_c.id
  tags = {
    Name = "${var.account2}-igw-3"
  }
}

## パブリック ルーティングテーブル
resource "aws_route_table" "public_rtb_c" {
  provider = aws.account2
  vpc_id   = aws_vpc.vpc_c.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_c.id
  }
  tags = {
    Name = "${var.account2}-public-rtb-3"
  }
}

## プライベート ルーティングテーブル
resource "aws_route_table" "private_rtb_c" {
  provider = aws.account2
  vpc_id   = aws_vpc.vpc_c.id

  tags = {
    Name = "${var.account1}-private-rtb-3"
  }
}

## プライベート ルーティングテーブル設定
resource "aws_route_table_association" "private_association_c" {
  provider       = aws.account2
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_rtb_c.id
}

## パブリック ルーティングテーブル設定
resource "aws_route_table_association" "public_association_c" {
  provider       = aws.account2
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rtb_c.id
}
