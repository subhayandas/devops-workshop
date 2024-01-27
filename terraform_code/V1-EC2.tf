provider "aws" {
  region = "us-east-1"
}

# Code for Instance EC2
resource "aws_instance" "devops-server" {
  ami = "ami-0a3c3a20c09d6f377"
  instance_type = "t2.micro"
  key_name = "devops-kp"

  for_each = toset(["jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.value}"
  }
}

# For security group
resource "aws_security_group" "devops-sg" {
  name = "devops-sg"
  description = "SG for Devops Resources"

  ingress {
    description = "SSH access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins access"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# Code for VPC
resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "devops-vpc"
  }
}

# code for subnet # 1
resource "aws_subnet" "devops-public-subnet-use1a" {
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "devops-public-subnet-use1a"
  }
}

# code for subnet # 2
resource "aws_subnet" "devops-public-subnet-use1b" {
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "devops-public-subnet-use1b"
  }
}

# IGW for VPC
resource "aws_internet_gateway" "devops-vpc-igw" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = {
    Name = "devops-vpc-igw"
  }
}

# ROute table association
resource "aws_route_table" "devops-vpc-public-rt" {
  vpc_id = aws_vpc.devops-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-vpc-igw.id
  }
}

# ROute table association # 1
resource "aws_route_table_association" "devops-rta-public-subnet-use1a" {
  subnet_id = aws_subnet.devops-public-subnet-use1a.id
  route_table_id = aws_route_table.devops-vpc-public-rt.id
}

# ROute table association # 2
resource "aws_route_table_association" "devops-rta-public-subnet-use1b" {
  subnet_id = aws_subnet.devops-public-subnet-use1b.id
  route_table_id = aws_route_table.devops-vpc-public-rt.id
}