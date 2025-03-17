provider "aws" {
  region = "eu-north-1"
}
terraform {
  backend "s3" {
    bucket = "tfstate-bucket-final-unique"     # S3 bucket where the state will be stored
    key    = "terraform.tfstate"        # Path to the state file in the bucket
    region = "eu-north-1"             # The AWS region
    dynamodb_table = "tfstate-lock-final"  # DynamoDB table used for state locking
    encrypt = true                       # Encrypt the state file in S3
  }
}
# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

# Associate Subnets with Route Table
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow HTTP, HTTPS, SSH, and Docker"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for SSH (not safe for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for HTTP
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for Docker (on port 8000)
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for Docker (on port 8000)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}


# EC2 Instance
resource "aws_instance" "app_server" {
  ami             = "ami-0c2e61fdcb5495691" # Replace with a valid AMI ID
  instance_type   = "t3.micro"
  key_name        = "hello"  # Update with your key pair
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.ec2_sg.id] # Fix: Use ID instead of name
  
  associate_public_ip_address = true
  depends_on = [aws_security_group.ec2_sg]

  tags = {
    Name = "MyAppServer"
  }
}

# Output the public IP of EC2 instance
output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

