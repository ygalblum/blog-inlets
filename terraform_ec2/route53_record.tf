data "aws_route53_zone" "selected" {
  name         = var.route53_zone_name
  private_zone = false
}


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "ghost-inlets.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.inlets.public_ip]
}
