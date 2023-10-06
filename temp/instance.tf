data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name      = "name"
    values    = ["RHEL-9.2.0_HVM*"]
  }
  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }
}

#resource "aws_instance" "public" {
#  count                       = 2
#  ami                         = data.aws_ami.rhel.id
#  associate_public_ip_address = true
#  instance_type               = "t2.micro"
#  key_name                    = "main"
#  vpc_security_group_ids      = [aws_security_group.public.id]
#  subnet_id                   = aws_subnet.public[count.index].id
#  user_data                   = file("user-data.sh")
#
#  tags = {
#    Name = "${var.env_code}-public"
#  }
#}

resource "aws_launch_configuration" "main" {
  image_id                    = data.aws_ami.rhel.id
  instance_type               = "t2.micro"
  name_prefix                 = "${var.env_code}-"
  security_groups             = [aws_security_group.public.id]
  user_data                   = file("user-data.sh")
  key_name                    = "main"

}

resource "aws_autoscaling_group" "main" {
  max_size              = 4
  min_size              = 2
  name                  = var.env_code
  desired_capacity      = 2

  target_group_arns     = [aws_lb_target_group.main.arn]
  launch_configuration  = aws_launch_configuration.main.name
  vpc_zone_identifier   = aws_subnet.public[*].id

  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true

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
          cidr_blocks = ["147.161.234.174/32"]
        }

        ingress {
          description = "HTTP from public"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["147.161.234.174/32"]
        }

        ingress {
          description     = "HTTP from load balancer"
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          security_groups = [aws_security_group.load_balancer.id]
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

resource "aws_instance" "private" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = "t2.micro"
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.private.id]
  subnet_id                   = aws_subnet.private[0].id

  tags = {
    Name = "${var.env_code}-private"
  }
}

resource aws_security_group "private" {
  name        = "${var.env_code}-private"
  description = "Allow VPC traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Everything"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_code}-private"
  }
}

