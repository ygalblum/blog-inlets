data "aws_route53_zone" "selected" {
  name         = var.route53_zone_name
  private_zone = false
}

locals {
  server_url = "${var.server_url_subdomain}.${data.aws_route53_zone.selected.name}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.server_url
  type    = "A"
  ttl     = 300
  records = [aws_instance.inlets_server.public_ip]
}
