resource "random_password" "token" {
  length      = 64
  special     = false
  min_lower   = 10
  min_numeric = 10
  min_upper   = 10
}

data "template_file" "user_data" {
  template = "${file("templates/userdata.tpl")}"

  vars = {
    token = "${random_password.token.result}"
    inlets_version = "${var.inlets_version}"
    domain = "${local.server_url}"
    lets_encrypt_issuer = "${var.letsencrypt_issuer}"
    lets_encrypt_email = "webmaster@${local.server_url}"
  }
}
