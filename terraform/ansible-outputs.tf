resource "local_file" "ansible_inventory" {
  content = yamlencode(
    {
      all: {
        hosts: {},
        children: {
          inlets-server: {
            hosts: {
              "${aws_instance.inlets_server.public_ip}": {}
            }
          },
          inlets-client: {
            hosts: {
              "${aws_instance.inlets_client.public_ip}": {}
            }
          }
        }
      }
    }
  )
  filename = "inventory.yml"
  file_permission = "0644"
}

resource "local_file" "ansible_values" {
  content = yamlencode(
    {
      inlets_version: "${var.inlets_version}",
      inlets_license: "${var.inlets_license}",
      inlets_server_ip: "${aws_instance.inlets_server.public_ip}",
      inlets_token: "${random_password.token.result}",
      lets_encrypt_domain: "${local.server_url}",
      lets_encrypt_issuer: "${var.letsencrypt_issuer}",
      lets_encrypt_email: "webmaster@${local.server_url}",
    }
  )
  filename = "values.yml"
  file_permission = "0644"
}
