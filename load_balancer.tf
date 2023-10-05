resource "aws_security_group" load_balancer {
  name        = "${var.env_code}-load_balancer"
  description = "Allow TCP 80 inbound to ELB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Port 80 to ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Everything"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-load_balancer"
  }
}

resource "aws_lb" "main" {
    name                = var.env_code
    internal            = false         # By default
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.load_balancer.id]
    subnets             = aws_subnet.public[*].id

    tags = {
      Name = "${var.env_code}-load_balancer"
  }
}

resource "aws_lb_target_group" "main" {
  name                = var.env_code
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.my_vpc.id

  health_check {
    enabled               = true
    path                  = "/"
    port                  = "traffic-port"
    healthy_threshold     = 5
    unhealthy_threshold   = 2
    timeout               = 5
    interval              = 30
    matcher               = 200   # Match HTTP code
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = 2

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.public[count.index].id
  port = 80
}

resource "aws_lb_listener" "main" {
  load_balancer_arn   = aws_lb.main.arn
  port                = 80
  protocol            = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

