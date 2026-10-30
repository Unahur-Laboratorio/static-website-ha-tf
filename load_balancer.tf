resource "aws_lb_target_group" "ha_tg" {
  name        = "ha-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.ha_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = { Name = "ha-tg" }
}

resource "aws_lb_target_group_attachment" "ha_web_a" {
  target_group_arn = aws_lb_target_group.ha_tg.arn
  target_id        = aws_instance.ha_web_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ha_web_b" {
  target_group_arn = aws_lb_target_group.ha_tg.arn
  target_id        = aws_instance.ha_web_b.id
  port             = 80
}

resource "aws_lb" "ha_alb" {
  name               = "ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ha_alb_sg.id]
  subnets = [
    aws_subnet.ha_public_subnet_a.id,
    aws_subnet.ha_public_subnet_b.id
  ]
  depends_on = [
    aws_route_table_association.ha_rt_assoc_a,
    aws_route_table_association.ha_rt_assoc_b
  ]
  tags = { Name = "ha-alb" }
}

resource "aws_lb_listener" "ha_listener" {
  load_balancer_arn = aws_lb.ha_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ha_tg.arn
  }
}