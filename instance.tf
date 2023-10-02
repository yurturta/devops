resource "aws_instance" "public" {
  ami                         = "ami-03cbad7144aeda3eb" # eu-central-1a
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource aws_security_group "public" {
        name        = "${var.env_code}-public"
        description = "Allow inbound traffic"
        vpc_id      = aws_vpc.my_vpc.id

        ingress {
          description = "SSH from public"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["147.161.234.99/32"]
        }
        egress {
          description = "Everything"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
  tags = {
    Name = "${var.env_code}-public"
  }
}
#  network_interface {
#    network_interface_id = aws_network_interface.foo.id
#    device_index         = 0
#  }