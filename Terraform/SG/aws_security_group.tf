provider "aws" {
  region     = "us-east-2"
}

resource "aws_security_group" "demo" {
  name        = "Devops-SG-1"
  vpc_id      = "vpc-0a4e054aadb3752b0"
  description = "My SG"
  tags = {
    Name = "Demo-SG"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Devops tool"
    protocol    = "TCP"
    from_port   = 8000
    to_port     = 9000
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh port"
    protocol    = "TCP"
    from_port   = 22
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
  }
}