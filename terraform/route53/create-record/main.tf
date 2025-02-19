resource "aws_route53_zone" "this" {
  name = var.domain
}

resource "aws_route53_record" "www-live" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 90
  }

  set_identifier = "live"
  records        = ["live.laygroud.store"]
}
