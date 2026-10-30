resource "aws_instance" "ha_web_a" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.ha_public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.ha_ec2_sg.id]
  associate_public_ip_address = true
  tags                        = { Name = "ha-web-a" }
}

resource "aws_instance" "ha_web_b" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.ha_public_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.ha_ec2_sg.id]
  associate_public_ip_address = true
  tags                        = { Name = "ha-web-b" }
}