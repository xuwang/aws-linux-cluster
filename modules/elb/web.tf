#
# ELB for www
#

variable "www_cert" { default = "certs/site.pem" }
variable "www_cert_chain" { default = "certs/rootCA.pem" }
variable "www_cert_key" { default = "certs/site-key.pem" }

resource "aws_elb" "www" {
  name = "www-elb"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${aws_security_group.elb.id}" ]
  subnets = ["${var.elb_subnet_a_id}","${var.elb_subnet_b_id}","${var.elb_subnet_c_id}"]
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8080
    instance_protocol = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }

  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/_ping"
    interval = 30
  }
}

# Upload a example/demo wildcard cert
resource "aws_iam_server_certificate" "wildcard" {
  name = "wildcard"
  certificate_body = "${file("${var.www_cert}")}"
  certificate_chain = "${file("${var.www_cert_chain}")}"
  private_key = "${file("${var.www_cert_key}")}"

  provisioner "local-exec" {
    command = <<EOF
echo # Sleep 10 secends so that aws_iam_server_certificate.wildcard is truely setup by aws iam service
echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
sleep 10
EOF
  }
}

# DNS registration
resource "aws_route53_record" "private-www" {
  zone_id = "${var.route53_private_zone_id}"
  name = "www"
  type = "A"
  
  alias {
    name = "${aws_elb.www.dns_name}"
    zone_id = "${aws_elb.www.zone_id}"
    evaluate_target_health = true
  }
}

/*
resource "aws_route53_record" "public-www" {
  zone_id = "${var.route53_public_zone_id}"
  name = "www"
  type = "A"
  
  alias {
    name = "${aws_elb.www.dns_name}"
    zone_id = "${aws_elb.www.zone_id}"
    evaluate_target_health = true
  }
}
*/

output "www_elb_id" {
    value = "${aws_elb.www.id}"
}

