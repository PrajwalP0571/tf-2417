# Create EC2 Instance
resource "aws_instance" "ibm-public-server" {
  ami           = "ami-03c983f9003cb9cd1"
  instance_type = "t2.micro"
  key_name = "730"
  subnet_id = aws_subnet.ibm-public-subnet.id
  vpc_security_group_ids = [aws_security_group.ibm-pub-sg.id]
  

  tags = {
    Name = "ibm-public-server"
  }
}