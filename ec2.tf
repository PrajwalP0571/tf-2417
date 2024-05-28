# Create EC2 Instance
resource "aws_instance" "food-public-server" {
  ami           = "ami-03c983f9003cb9cd1"
  instance_type = "t2.micro"
  key_name = "730"
  subnet_id = aws_subnet.food-public-subnet.id
  vpc_security_group_ids = [aws_security_group.food-pub-sg.id]
  user_data  = file("ecomm.sh")

  tags = {
    Name = "food-public-server"
  }
}