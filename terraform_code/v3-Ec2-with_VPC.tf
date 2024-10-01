provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-Server" {
    ami = "ami-0e86e20dae9224db8"
    instance_type = "t2.micro"
    key_name = "devopsp"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.dppj-public-subnet-01.id
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.dppj-vpc.id

   ingress {
    description = "SSH access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dppj-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "dppj-vpc"
    }
}

resource "aws_subnet" "dppj-public-subnet-01" {
  vpc_id = aws_vpc.dppj-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    name = "dppj-public-submit-01"
  }
}

resource "aws_subnet" "dppj-public-subnet-02" {
  vpc_id = aws_vpc.dppj-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    name = "dppj-public-submit-02"
  }
}

resource "aws_internet_gateway" "dppj-igw" {
  vpc_id = aws_vpc.dppj-vpc.id
  tags = {
    Name = "dppj-igw"
  }
}

resource "aws_route_table" "dppj-public-rt" {
  vpc_id = aws_vpc.dppj-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dppj-igw.id
  }
}

resource "aws_route_table_association" "dppj_rta-public-subnet-01" {
  subnet_id = aws_subnet.dppj-public-subnet-01.id
  route_table_id = aws_route_table.dppj-public-rt.id
}

resource "aws_route_table_association" "dppj_rta-public-subnet-02" {
  subnet_id = aws_subnet.dppj-public-subnet-02.id
  route_table_id = aws_route_table.dppj-public-rt.id
}