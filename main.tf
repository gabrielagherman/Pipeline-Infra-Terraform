provider "aws" {
  region  = "eu-central-1"
}

resource "aws_vpc" "gabriela_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Gabriela VPC"
  }
}

resource "aws_subnet" "gabriela_public_subnet" {
  vpc_id            = aws_vpc.gabriela_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Gabriela Public Subnet"
  }
}

resource "aws_subnet" "gabriela_private_subnet" {
  vpc_id            = aws_vpc.gabriela_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Gabriela Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.gabriela_vpc.id

  tags = {
    Name = "Gabriela Internet Gateway"
  }
}

resource "gabriela_aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gabriela_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gabriela_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gabriela_ig.id
  }

  tags = {
    Name = "Gabriela Public Route Table"
  }
}

resource "gabriela_aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.gabriela_public_subnet.id
  route_table_id = gabriela_aws_route_table.public_rt.id
}

resource "gabriela_aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.gabriela_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web_instance" {
  ami           = "ami-0d1ddd83282187d18"
  instance_type = "t2.micro"
  key_name      = "aws-key"

  subnet_id                   = aws_subnet.gabriela_public_subnet.id
  vpc_security_group_ids      = [gabriela_aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    "Name" : "Gabriela_PC"
  }
}
