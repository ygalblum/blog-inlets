data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  myip_cidr = "${chomp(data.http.myip.response_body)}/32"
}
