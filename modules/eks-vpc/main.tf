/* Create a dedicated VPC for EKS Cluster */
resource "aws_vpc" "eks-cluster-vpc" {
  cidr_block           = var.vpc-cidr-block
  instance_tenancy     = var.instanceTenancy
  enable_dns_hostnames = var.dnsHostNames

  tags = {
    Name    = "${var.eks-cluster-name}-vpc",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* IGW for Public Subnet */
resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  depends_on = [
    aws_vpc.eks-cluster-vpc
  ]

  tags = {
    Name    = "${var.team}-igw",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Public Subnet for launching facing Public EKS Worker Nodes */
resource "aws_subnet" "eks-cluster-public-subnet" {
  vpc_id                  = aws_vpc.eks-cluster-vpc.id
  cidr_block              = var.public-subnet-cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public-subnet-aws-az

  depends_on = [
    aws_vpc.eks-cluster-vpc
  ]

  tags = {
    Name    = "eks-public-subnet",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Private Subnet for launching facing Public EKS Worker Nodes */
resource "aws_subnet" "eks-cluster-private-subnet" {
  vpc_id                  = aws_vpc.eks-cluster-vpc.id
  cidr_block              = var.private-subnet-cidr
  map_public_ip_on_launch = true
  availability_zone       = var.private-subnet-aws-az

  depends_on = [
    aws_vpc.eks-cluster-vpc
  ]

  tags = {
    Name    = "eks-private-subnet",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Security Group for NAT Instance */
resource "aws_security_group" "nat-sg" {
  name   = "${var.eks-cluster-name}-vpc-nat-sg"
  vpc_id = aws_vpc.eks-cluster-vpc.id

  depends_on = [
    aws_vpc.eks-cluster-vpc
  ]

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.private-subnet-cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private-subnet-cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc-cidr-block]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.team}-nat-sg",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* NAT Instance for communicating to Private Subnet */
resource "aws_instance" "nat-instance" {
  ami                         = "ami-023fe09ce43d87de4"
  availability_zone           = var.public-subnet-aws-az
  instance_type               = "m1.small"
  vpc_security_group_ids      = [aws_security_group.nat-sg.id]
  subnet_id                   = aws_subnet.eks-cluster-public-subnet.id
  associate_public_ip_address = true
  source_dest_check           = false

  depends_on = [
    aws_security_group.nat-sg
  ]

  tags = {
    Name    = "${var.team}-nat",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Attaching EIP to NAT Instance */
resource "aws_eip" "eip-for-nat-instance" {
  instance = aws_instance.nat-instance.id
  vpc      = true

  depends_on = [
    aws_instance.nat-instance
  ]

  tags = {
    Name    = "${var.team}-nat-instance-eip",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Public Route Table */
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name    = "${var.team}-public-rtb",
    Cluster = var.eks-cluster-name,
    Team    = var.team,
    Owner   = var.team,
    Plan    = "dedicated",
    Type    = "Public Route Table"
  }
}

/* Private Route Table */
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat-instance.id
  }

  tags = {
    Name    = "${var.team}-private-rtb",
    Cluster = var.eks-cluster-name,
    Team    = var.team,
    Owner   = var.team,
    Plan    = "dedicated",
    Type    = "Private Route Table"
  }
}

/* Public Route Table Association */
resource "aws_route_table_association" "public-route-table-assocation" {
  subnet_id      = aws_subnet.eks-cluster-public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

/* Private Route Table Association */
resource "aws_route_table_association" "private-route-table-assocation" {
  subnet_id      = aws_subnet.eks-cluster-private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}
