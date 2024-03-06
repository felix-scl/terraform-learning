resource "aws_vpc" "learning_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "learning_subnet" {
  vpc_id                  = aws_vpc.learning_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.learning_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.learning_vpc.id

  tags = {
    Name = "dev-rt"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.learning_subnet.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.learning_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}