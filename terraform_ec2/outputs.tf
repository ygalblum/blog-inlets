output "external_ip" {
  description = "Inlets server Public IP address"
  value = aws_instance.inlets.public_ip
}

output "token" {
  description = "Inlets server token"
  value = random_password.token.result
  sensitive = true
}
