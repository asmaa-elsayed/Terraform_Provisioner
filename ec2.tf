provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
ami = var.ami
instance_type = var.instance_type
key_name = aws_key_pair.deployer1.key_name
vpc_security_group_ids = [aws_security_group.allow_tls1.id]

provisioner "remote-exec" {
  inline = [
     "sudo yum install httpd",
     "sudo systemctl start httpd",
     "sudo systemctl enable httpd",
     "echo 'Asmaa' > /var/www/html/index.html"
  ]
}
connection {
  type = "ssh"
  host = self.public_ip
  user = "ec2-user"
  private_key = file(var.private_key_location)
}

tags = {
Name = var.ec2_tag
}
}
resource "aws_key_pair" "deployer1" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}

resource "aws_security_group" "allow_tls1" {
  name        = "allow_tls1"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.sg_tag
  }
}

