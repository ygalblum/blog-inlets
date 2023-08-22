data "aws_vpc" "current" {
}

locals {
  vpc_cidr_block = "${data.aws_vpc.current.cidr_block}"
}
