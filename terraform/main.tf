resource "aws_instance" "inlets_server" {
    tags = {
        Name = "Inlets-Server"
    }

    ami           = data.aws_ami.inlets_ami.id
    instance_type = var.inlets_instance_type

    key_name = aws_key_pair.inlets_key_pair.key_name

    vpc_security_group_ids = [
      aws_security_group.ssh.id,
      aws_security_group.http.id,
      aws_security_group.inlets_wss.id,
      aws_security_group.outbound.id,
    ]

    root_block_device {
      volume_size = var.inlets_volume_size
    }
}

resource "aws_instance" "inlets_client" {
    tags = {
        Name = "Inlets-Client"
    }

    ami           = data.aws_ami.inlets_ami.id
    instance_type = var.inlets_instance_type

    key_name = aws_key_pair.inlets_key_pair.key_name

    vpc_security_group_ids = [
      aws_security_group.ssh.id,
      aws_security_group.outbound.id,
    ]

    root_block_device {
      volume_size = var.inlets_volume_size
    }
}
