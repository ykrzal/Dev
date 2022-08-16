resource "aws_route53_zone" "zoom_dns" {
  name = "zoom.dns"
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zoom_dns.zone_id
  name    = "test3.zoom.dns"
  type    = "A"
  ttl     = 300
  records = aws_eip.vpn.public_ip
}
