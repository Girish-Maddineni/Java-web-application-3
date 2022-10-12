provider "aws" {
  region     = "us-east-2"

}

resource "aws_instance" "demo" {
  ami                         = "ami-0c6a6b0e75b2b6ce7"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0e580cf89173b9f25"
  associate_public_ip_address = true
  key_name                    = "AWS-NEW-KEY-PAIR"
  vpc_security_group_ids      = ["sg-022728ee63c034878"]
  count                       = 1
  tags = {
    Name = "demo"
  }
}