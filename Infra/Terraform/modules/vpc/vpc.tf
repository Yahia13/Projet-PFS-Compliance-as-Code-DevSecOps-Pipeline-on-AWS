//VPC 
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
// ---private subnets for EKS nodes and optionnally ec2 of jenkins ---
resource "aws_subnet" "Private_subnet_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-subnet-1a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_subnet" "Private_subnet_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"


  tags = {
    Name = "${var.project_name}-private-subnet-1b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
// ---public subnets for ALB and NAT gateways ---
resource "aws_subnet" "Public_subnet_1a" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-public-subnet-1a"
        "kubernetes.io/role/elb" = "1"

    }
}

resource "aws_subnet" "Public_subnet_1b" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.12.0/24"
    availability_zone = "${var.aws_region}b"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-public-subnet-1b"
        "kubernetes.io/role/elb" = "1"

    }
}

#-- Internet Gateway for public subnets ---
resource "aws_internet_gateway" "IGW" {
      vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
  
}

