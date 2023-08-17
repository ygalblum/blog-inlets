resource "aws_security_group" "inlets_wss" {
  name = "Inlets WSS"
  description = "Security group for inlets wss"
}

resource "aws_vpc_security_group_ingress_rule" "inlets_wss" {
  security_group_id = aws_security_group.inlets_wss.id

  ip_protocol = "tcp"
  from_port = var.inlets_wss_port
  to_port = var.inlets_wss_port
  cidr_ipv4 = local.myip_cidr
}
