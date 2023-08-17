data "aws_ami" "inlets_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.inlets_ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = [var.inlets_ami_owner]
}
