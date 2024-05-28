# Create VPC
resource "aws_vpc" "food-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "food-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "food-public-subnet" {
  vpc_id     = aws_vpc.food-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "food public subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "food-private-subnet" {
  vpc_id     = aws_vpc.food-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "food private subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "food-igw" {
  vpc_id = aws_vpc.food-vpc.id

  tags = {
    Name = "food internet"
  }
}

# Create Public Routing
resource "aws_route_table" "food-pub-rt" {
  vpc_id = aws_vpc.food-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.food-igw.id
  }

  tags = {
    Name = "food public route table"
  }
}

# Create Public Association For Routing
resource "aws_route_table_association" "food-public-rt-asc" {
  subnet_id      = aws_subnet.food-public-subnet.id
  route_table_id = aws_route_table.food-pub-rt.id
}

# Create Elastic IP
resource "aws_eip" "food-eip-nat" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "food-nat-gw" {
  allocation_id = aws_eip.food-eip-nat.id
  subnet_id     = aws_subnet.food-public-subnet.id

  tags = {
    Name = "food nat gateway"
  }
  # depends_on = [aws_internet_gateway.example]
}

# Create Public NACL
resource "aws_network_acl" "food-pub-nacl" {
  vpc_id = aws_vpc.food-vpc.id

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
    Name = "food-public-nacl"
  }
}

# Create Private NACL
resource "aws_network_acl" "food-pvt-nacl" {
  vpc_id = aws_vpc.food-vpc.id

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
    Name = "food-private-nacl"
  }
}

# Create Public NACL Association
resource "aws_network_acl_association" "food-public-nacl-assc" {
  network_acl_id = aws_network_acl.food-pub-nacl.id
  subnet_id      = aws_subnet.food-public-subnet.id
}

# Create Private NACL Association
resource "aws_network_acl_association" "food-private-nacl-assc" {
  network_acl_id = aws_network_acl.food-pvt-nacl.id
  subnet_id      = aws_subnet.food-private-subnet.id
}

# Create Public Security Group
resource "aws_security_group" "food-pub-sg" {
  name        = "food-pub-sg"
  description = "Allow SSH & HTTP"
  vpc_id      = aws_vpc.food-vpc.id

  tags = {
    Name = "food-public-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "food-pub-ssh" {
  security_group_id = aws_security_group.food-pub-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "food-pub-http" {
  security_group_id = aws_security_group.food-pub-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Security Group Out Bound Rule
resource "aws_vpc_security_group_egress_rule" "food-all-traffic" {
  security_group_id = aws_security_group.food-pub-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create Private Security Group
resource "aws_security_group" "food-pvt-sg" {
  name        = "food-pvt-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.food-vpc.id

  tags = {
    Name = "food-private-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "food-pvt-ssh" {
  security_group_id = aws_security_group.food-pvt-sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "food-pvt-pg" {
  security_group_id = aws_security_group.food-pvt-sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

# Security Group Out Bound Rule
resource "aws_vpc_security_group_egress_rule" "food-all-traffic-pvt" {
  security_group_id = aws_security_group.food-pvt-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}