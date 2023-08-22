output "external_ip" {
  description = "Inlets server Public IP address"
  value = aws_instance.inlets_server.public_ip
}
