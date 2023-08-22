resource "local_file" "ansible_inventory" {
  content = yamlencode(
    {
      all: {
        hosts: {},
        children: {
          inlets-server: {
            hosts: {
              "${aws_instance.inlets_server.public_ip}": {
                ansible_user: "ec2-user",
                ansible_ssh_private_key_file: "${path.cwd}/${var.key_pair_name}.pem",
                ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
              }
            }
          },
          inlets-client: {
            hosts: {
              "${aws_instance.inlets_client.public_ip}": {
                ansible_user: "ec2-user",
                ansible_ssh_private_key_file: "${path.cwd}/${var.key_pair_name}.pem",
                ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
              }
            }
          }
        }
      }
    }
  )
  filename = "${path.cwd}/inventory.yml"
  file_permission = "0644"
}

resource "local_file" "ansible_values" {
  content = yamlencode(
    {
      inlets_version: "${var.inlets_version}",
      inlets_license: "${var.inlets_license}",
      inlets_server_ip: "${aws_instance.inlets_server.public_ip}",
      lets_encrypt_domain: "${local.server_url}",
    }
  )
  filename = "${path.cwd}/values.yml"
  file_permission = "0644"
}
