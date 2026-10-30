output "vpc_id" {
  value = aws_vpc.ha_vpc.id
}

output "instance_a_id" {
  value = aws_instance.ha_web_a.id
}

output "instance_a_private_ip" {
  value = aws_instance.ha_web_a.private_ip
}

output "instance_a_public_ip" {
  value = aws_instance.ha_web_a.public_ip
}

output "instance_b_id" {
  value = aws_instance.ha_web_b.id
}

output "instance_b_private_ip" {
  value = aws_instance.ha_web_b.private_ip
}

output "instance_b_public_ip" {
  value = aws_instance.ha_web_b.public_ip
}

output "alb_dns_name" {
  value = aws_lb.ha_alb.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.ha_alb.dns_name}"
}

output "alb_arn" {
  value = aws_lb.ha_alb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.ha_tg.arn
}