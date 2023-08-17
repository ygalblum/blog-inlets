resource "aws_security_group" "http" {
  name = "Inlets - HTTP Access"
  description = "Security group for the HTTP access to inlets exit"
}

resource "aws_vpc_security_group_ingress_rule" "inlets_http" {
  security_group_id = aws_security_group.http.id

  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "inlets_https" {
  security_group_id = aws_security_group.http.id

  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_ipv4 = "0.0.0.0/0"
}
