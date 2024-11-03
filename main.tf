# Definindo credentials AWS
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.session_token
}

# Criando uma VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

# Criando subnet pública A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_a"
  }
}

# Criando subnet pública B
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.16/28"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_b"
  }
}

# Criando subnet privada A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.32/28"
  availability_zone = "${var.region}a"
  tags = {
    Name = "private_subnet_a"
  }
}

# Criando subnet privada B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.48/28"
  availability_zone = "${var.region}b"
  tags = {
    Name = "private_subnet_b"
  }
}

# Criando subnet Group para o RDS
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "rds_subnet_group"
  }
}

# Criando o Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main_igw"
  }
}

# Criando Route Table para subnets públicas
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

# Associando Route Table com as Sub-redes Públicas
resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Criando Security Group para o RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  name   = "rds_sg"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

# Criando RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = "db-postgress"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "${var.user_pg}"
  password               = "${var.passwd_pg}"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.id

  tags = {
    Name = "postgres_db"
  }
}

# Criando Security Group para EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ec2_sg"

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

  tags = {
    Name = "ec2_security_group"
  }
}

# Criando EC2 A
resource "aws_instance" "ec2_a" {
  ami                    = "ami-0ebfd941bbafe70c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "ec2_instance_a"
  }
}

# Criando EC2 B
resource "aws_instance" "ec2_b" {
  ami                    = "ami-0ebfd941bbafe70c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "ec2_instance_b"
  }
}