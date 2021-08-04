#security group

resource "aws_security_group" "tomcat" {
  name        = "tomcat"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress {
    description      = "SSH  from VPC"
    from_port        = 22
    to_port          = 22
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
    Name = "${var.envname}-tomcat-sg"
  }
}

data "template_file" "user_data" {
  template = "${file("tomcat_install.sh")}"
  } 

#ec2
resource "aws_instance" "tomcat" {
  ami           = var.ami
  instance_type = var.type
  subnet_id     = aws_subnet.prisubnets[0].id
  key_name      = aws_key_pair.petclinic.id
  vpc_security_group_ids = ["${aws_security_group.tomcat.id}"]
  user_data = data.template_file.user_data.rendered
  

   tags = {
    Name = "${var.envname}-tomcat"
  }
}