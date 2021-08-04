#security group

resource "aws_security_group" "bastion" {
  name        = "bastion"
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
    Name = "${var.envname}-bastion-sg"
  }
}

#key

resource "aws_key_pair" "petclinic" {
  key_name   = "petclinic-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKjxSHptcDkC9QoqWf8bbL6sopAH9xbWWzXaObfuP9QnVE+BmM3+hp6fIjcNPPJLEUCw7HNPqzo6Y/WnsqqPOsyA80j+IP9xozSbUxBxJY7L4K/dp4H5DvBZxLXZP842nFM4C8hk2EKl9CnVvIQXl1xCGUpRyYeQlbIns8gvWpCclttL/963sS7DqRA5458f0xhPyFawMeZHphA1JROHcbm+BWe9zO8CZ/x9y2FOu19lMvhuxbqS22TA0532S9bNsHkXq1kK8JWojChj6dldu0zoXcjcVeiZnfKO9p1/z4OOj/IZBY2ZHzEtwQOpgpiy7Y0tQX972SSZEHQx8fYrvIOKVpU/cYPYbWAjQvm4lUp+DYNF5hW0XuqRk9S4A/02OXhMrLqOmfC8yVqesKL+Rq4v9REQRTdOhpKqJbqzevAT9euM9+AFVdnA/L4t7j8pp5qXlJyiwrmOeiqGzBi7y4shrJX8tVFt97o07upMmaOpCtoln9mCKtCCjJO9erXW8="
}


#ec2
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.type
  subnet_id     = aws_subnet.pubsubnet[0].id
  key_name      = aws_key_pair.petclinic.id
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

   tags = {
    Name = "${var.envname}-bastion"
  }
}









