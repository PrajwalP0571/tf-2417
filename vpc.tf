# Create VPC
resource "aws_vpc" "ibm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ibm-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "ibm-public-subnet" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm public subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "ibm-private-subnet" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ibm private subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ibm-igw" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm internet"
  }
}

# Create Public Routing
resource "aws_route_table" "ibm-pub-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm public route table"
  }
}

# Create Public Association For Routing
resource "aws_route_table_association" "ibm-public-rt-asc" {
  subnet_id      = aws_subnet.ibm-public-subnet.id
  route_table_id = aws_route_table.ibm-pub-rt.id
}

# Create Elastic IP
resource "aws_eip" "ibm-eip-nat" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "ibm-nat-gw" {
  allocation_id = aws_eip.ibm-eip-nat.id
  subnet_id     = aws_subnet.ibm-public-subnet.id

  tags = {
    Name = "ibm nat gateway"
  }
  # depends_on = [aws_internet_gateway.example]
}

# Create Public NACL
resource "aws_network_acl" "ibm-pub-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-public-nacl"
  }
}

# Create Private NACL
resource "aws_network_acl" "ibm-pvt-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-private-nacl"
  }
}

# Create Public NACL Association
resource "aws_network_acl_association" "ibm-public-nacl-assc" {
  network_acl_id = aws_network_acl.ibm-pub-nacl.id
  subnet_id      = aws_subnet.ibm-public-subnet.id
}

# Create Private NACL Association
resource "aws_network_acl_association" "ibm-private-nacl-assc" {
  network_acl_id = aws_network_acl.ibm-pvt-nacl.id
  subnet_id      = aws_subnet.ibm-private-subnet.id
}

# Create Public Security Group
resource "aws_security_group" "ibm-pub-sg" {
  name        = "ibm-pub-sg"
  description = "Allow SSH & HTTP"
  vpc_id      = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-public-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ibm-pub-ssh" {
  security_group_id = aws_security_group.ibm-pub-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ibm-pub-http" {
  security_group_id = aws_security_group.ibm-pub-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}