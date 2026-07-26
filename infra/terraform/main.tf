terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ───────────────────────────────────────────────────────────
resource "aws_vpc" "shelfsense_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "shelfsense-vpc"
    Project = "shelfsense"
  }
}

# ── Internet Gateway ──────────────────────────────────────────────
resource "aws_internet_gateway" "shelfsense_igw" {
  vpc_id = aws_vpc.shelfsense_vpc.id

  tags = {
    Name    = "shelfsense-igw"
    Project = "shelfsense"
  }
}

# ── Public Subnet ─────────────────────────────────────────────────
resource "aws_subnet" "shelfsense_subnet" {
  vpc_id                  = aws_vpc.shelfsense_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "shelfsense-subnet"
    Project = "shelfsense"
  }
}

# ── Route Table ───────────────────────────────────────────────────
resource "aws_route_table" "shelfsense_rt" {
  vpc_id = aws_vpc.shelfsense_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shelfsense_igw.id
  }

  tags = {
    Name    = "shelfsense-rt"
    Project = "shelfsense"
  }
}

resource "aws_route_table_association" "shelfsense_rta" {
  subnet_id      = aws_subnet.shelfsense_subnet.id
  route_table_id = aws_route_table.shelfsense_rt.id
}

# ── Security Group — App Server ───────────────────────────────────
resource "aws_security_group" "shelfsense_app_sg" {
  name        = "shelfsense-app-sg"
  description = "App server: SSH from my IP, HTTP and port 5000 from anywhere"
  vpc_id      = aws_vpc.shelfsense_vpc.id

  # SSH — only from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "SSH from admin IP only"
  }

  # HTTP — public
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP public access"
  }

  # Flask — public
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask app direct access"
  }

  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "shelfsense-app-sg"
    Project = "shelfsense"
  }
}

# ── Security Group — DB Server ────────────────────────────────────
resource "aws_security_group" "shelfsense_db_sg" {
  name        = "shelfsense-db-sg"
  description = "DB server: SSH from my IP, PostgreSQL from app server only"
  vpc_id      = aws_vpc.shelfsense_vpc.id

  # SSH — only from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "SSH from admin IP only"
  }

  # PostgreSQL — from app server subnet
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
    description = "PostgreSQL from app subnet only"
  }

  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "shelfsense-db-sg"
    Project = "shelfsense"
  }
}

# ── EC2 — App Server ──────────────────────────────────────────────
resource "aws_instance" "shelfsense_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.shelfsense_subnet.id
  vpc_security_group_ids = [aws_security_group.shelfsense_app_sg.id]

  tags = {
    Name    = "shelfsense-app"
    Project = "shelfsense"
    Role    = "app"
  }
}

# ── EC2 — DB Server ───────────────────────────────────────────────
resource "aws_instance" "shelfsense_db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.shelfsense_subnet.id
  vpc_security_group_ids = [aws_security_group.shelfsense_db_sg.id]

  tags = {
    Name    = "shelfsense-db"
    Project = "shelfsense"
    Role    = "db"
  }
}
