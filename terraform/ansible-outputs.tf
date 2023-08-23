resource "local_file" "ansible_inventory" {
  content = yamlencode(
    {
      all: {
        vars: {
          ansible_user: "ec2-user",
          ansible_ssh_private_key_file: "${local_sensitive_file.ssh_key.filename}",
          ansible_ssh_common_args: "-o StrictHostKeyChecking=no",
          inlets_server_domain: "${local.server_url}",
        }
        hosts: {},
        children: {
          inlets_server: {
            hosts: {
              "${aws_instance.inlets_server.public_ip}": {}
            }
          },
          inlets_client: {
            hosts: {
              "${aws_instance.inlets_client.public_ip}": {}
            }
          }
        }
      }
    }
  )
  filename = "${path.cwd}/inventory.yml"
  file_permission = "0644"
}
