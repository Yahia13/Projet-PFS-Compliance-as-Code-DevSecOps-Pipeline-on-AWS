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

#--- eips for NAT gateways ---
resource "aws_eip" "eip_for_nat_1a" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-az-a"
  }
}

resource "aws_eip" "eip_for_nat_1b" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-az-b"
  }
}
#--- NAT gateways for private subnets ---
resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.eip_for_nat_1a.id
  subnet_id     = aws_subnet.Private_subnet_1a

  tags = {
    Name = "gw NATa"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "nat_gw_1b" {
  allocation_id = aws_eip.eip_for_nat_1b.id
  subnet_id     = aws_subnet.Private_subnet_1b

  tags = {
    Name = "gw NATb"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

#--- Route tables ---
# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.Public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.Public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table
resource "aws_route_table" "private_rt_az_a" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-rt-az-a"
  }
}

resource "aws_route" "private_internet_az_a" {
  route_table_id         = aws_route_table.private_rt_az_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1a.id
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.Private_subnet_1a.id
  route_table_id = aws_route_table.private_rt_az_a.id
}

resource "aws_route_table" "private_rt_az_b" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-rt-az-b"
  }
}
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.Private_subnet_1b.id
  route_table_id = aws_route_table.private_rt_az_b.id
}

resource "aws_route" "private_internet_az_b" {
  route_table_id         = aws_route_table.private_rt_az_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1b.id
}