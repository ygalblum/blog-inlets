resource "tls_private_key" "inlets_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "inlets_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.inlets_key.public_key_openssh

  provisioner "local-exec"{
    command = "echo '${tls_private_key.inlets_key.private_key_pem}' > ./${var.key_pair_name}.pem"
  }
}
