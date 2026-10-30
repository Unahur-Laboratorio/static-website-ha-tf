resource "aws_security_group" "ha_alb_sg" {
  name        = "ha-alb-sg"
  description = "HTTP publico al ALB"
  vpc_id      = aws_vpc.ha_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ha-alb-sg" }
}

resource "aws_security_group" "ha_ec2_sg" {
  name        = "ha-ec2-sg"
  description = "HTTP desde ALB y SSH administrativo"
  vpc_id      = aws_vpc.ha_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ha_alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ha-ec2-sg" }
}