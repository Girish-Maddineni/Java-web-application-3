provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  tags = {
    "Name" = "my-vpc"
  }
  cidr_block           = var.cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
}

resource "aws_subnet" "pub-subnet-1" {
  cidr_block              = "10.1.0.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.zones.names[0]
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "pub-subnet-1"
  }
}

resource "aws_subnet" "pub-subnet-2" {
  cidr_block              = "10.1.1.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.zones.names[1]
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "pub-subnet-2"
  }
}

resource "aws_subnet" "priv-subnet-1" {
  cidr_block        = "10.1.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.zones.names[0]
  tags = {
    "Name" = "priv-subnet-1"
  }
}

resource "aws_subnet" "priv-subnet-2" {
  cidr_block        = "10.1.3.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.zones.names[1]
  tags = {
    "Name" = "priv-subnet-2"
  }
}

resource "aws_internet_gateway" "my-ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "my-ig"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "my-pub-rt"
  }
  route {
    cidr_block = var.all-traffic
    gateway_id = aws_internet_gateway.my-ig.id
  }
  depends_on = [
    aws_internet_gateway.my-ig
  ]
}

resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "my-priv-rt"
  }
  route {
    cidr_block     = var.all-traffic
    nat_gateway_id = aws_nat_gateway.my-nat.id
  }
  depends_on = [
    aws_nat_gateway.my-nat
  ]
}

resource "aws_eip" "demoeip" {
  vpc = true
  tags = {
    "Name" = "demo-eip"
  }
}

resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.demoeip.id
  subnet_id     = aws_subnet.pub-subnet-1.id
  tags = {
    "Name" = "My-Nat"
  }
}

resource "aws_route_table_association" "pub-1-sub-association" {
  route_table_id = aws_route_table.pub-rt.id
  subnet_id      = aws_subnet.pub-subnet-1.id
}

resource "aws_route_table_association" "pub-2-sub-association" {
  route_table_id = aws_route_table.pub-rt.id
  subnet_id      = aws_subnet.pub-subnet-2.id
}

resource "aws_route_table_association" "priv-1-sub-association" {
  route_table_id = aws_route_table.priv-rt.id
  subnet_id      = aws_subnet.priv-subnet-1.id
}

resource "aws_route_table_association" "priv-2-sub-association" {
  route_table_id = aws_route_table.priv-rt.id
  subnet_id      = aws_subnet.priv-subnet-2.id
}

resource "aws_security_group" "my-sg" {
  name   = "my-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "ssh port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all-traffic]
  }

  egress {
    description = "outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all-traffic]
  }
}

resource "aws_network_acl" "my-acl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.pub-subnet-1.id, aws_subnet.pub-subnet-2.id, aws_subnet.priv-subnet-1.id, aws_subnet.priv-subnet-2.id]
  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_block = var.all-traffic
  }
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_block = var.all-traffic
  }
  tags = {
    "Name" = "my-acl"
  }
}

# resource "aws_key_pair" "pem" {
#   key_name   = "mykey-1"
#   public_key = file("/Users/girish.maddineni/.ssh/id_rsa.pub")
# }

resource "aws_instance" "ec2" {
  ami                         = "ami-08e2d37b6a0129927"
  associate_public_ip_address = "true"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
#   key_name                    = aws_key_pair.pem.key_name
  key_name                    = "mykey-1"
  tags = {
    "Name" = "demo"
  }
  depends_on = [
    aws_security_group.my-sg
  ]

}

output "public-ip" {
  description = "ec2-pulic-ip"
  value       = aws_instance.ec2.public_ip
}