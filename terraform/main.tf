provider "aws" {}

resource "aws_instance" "ec2" {
    ami = "ami-08e2d37b6a0129927"
    instance_type = "t2.micro"
    subnet_id = "subnet-055b559efa38b65a7"
    vpc_security_group_ids = [ "sg-08456076973730290" ]
    tags = {
        Name = "demo-ec2"
    }
}