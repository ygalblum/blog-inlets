variable "key_pair_name" {
  type = string
  default = "inlets"
}

variable "inlets_ami_name" {
    type = string
    default = "CentOS Stream 9 *"
}

variable "inlets_ami_owner" {
    type = string
    default = "125523088429"
}

variable "inlets_instance_type" {
    type = string
    default = "t3.nano"
}

variable "inlets_volume_size" {
    type = number
    default = 20
}

variable "ssh_port" {
    type = number
    default = 22
}

variable "inlets_wss_port" {
    type = number
    default = 8123
}

variable "route53_zone_name" {
    type = string
}

variable "server_url_subdomain" {
    type = string
    default = "ghost"
}
