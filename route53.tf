
/*

resource "aws_route53_record" "ranch-ewr-1" {
  zone_id = "${var.route53_zone_id}"
  name    = "ranch-ewr-1.${var.fqdn}"
  type    = "A"
  ttl     = "300"
  records = [
    "${packet_device.ranch-ewr-1-s1.network.0.address}",
    "${packet_device.ranch-ewr-1-s2.network.0.address}"
  ]
}

resource "aws_route53_record" "ranch-ewr-1-s1" {
  zone_id = "${var.route53_zone_id}"
  name    = "ranch-ewr-1-s1.${var.fqdn}"
  type    = "A"
  ttl     = "300"
  records = [
    "${packet_device.ranch-ewr-1-s1.network.0.address}"
  ]
}

resource "aws_route53_record" "ranch-ewr-1-s2" {
  zone_id = "${var.route53_zone_id}"
  name    = "ranch-ewr-1-s2.${var.fqdn}"
  type    = "A"
  ttl     = "300"
  records = [
    "${packet_device.ranch-ewr-1-s2.network.0.address}"
  ]
}


resource "aws_route53_record" "ranch-ewr-1-a1" {
  zone_id = "${var.route53_zone_id}"
  name    = "ranch-ewr-1-a1.${var.fqdn}"
  type    = "A"
  ttl     = "300"
  records = [
    "${packet_device.ranch-ewr-1-a1.network.0.address}"
  ]
}
*/