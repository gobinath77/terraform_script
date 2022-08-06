resource "aws_vpc" "my_vpc_pub" {
  cidr_block       = "10.200.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow ALL traffic"
  vpc_id      = aws_vpc.my_vpc_pub.id

  ingress {
    description = "All Traffic from VPC"
    from_port   = 0
    to_port     = 65535
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
    Name = "my_sg"
  }
}
resource "aws_subnet" "my_sub_pub" {
  vpc_id     = aws_vpc.my_vpc_pub.id
  cidr_block = "10.200.1.0/24"

  tags = {
    Name = "my_sub_pub"
  }
}
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc_pub.id

  tags = {
    Name = "my_gw"
  }
}
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc_pub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "my_rt"
  }
}
resource "aws_route_table_association" "my_rt" {
  subnet_id      = aws_subnet.my_sub_pub.id
  route_table_id = aws_route_table.my_rt.id
}
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
    file_permission = "400"
}
resource "aws_instance" "httpd_pub" {
  count                       = 1
  ami                         = "ami-0cff7528ff583bf9a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_sub_pub.id
  associate_public_ip_address = true
  key_name                    = "TF_key"
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  user_data                   = <<-EOF
                #!/bin/bash
                yum install httpd -y
                systemctl enable httpd
                systemctl start httpd
	               touch /var/www/html/index.html
           	    echo "<h4> Infrastructure Deployed Sucessfully </h4>" > /var/www/html/index.html
                EOF

  tags = {
    Name = "httpd_pub"
  }
}
