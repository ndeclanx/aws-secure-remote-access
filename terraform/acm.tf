###############################################################################
# ACM Certificate Imports
#
# AWS Client VPN requires certificates to be imported into ACM.
# Run scripts/generate-certs.sh first to populate the certs/ directory.
#
# For production with >10 users, consider AWS Private CA instead:
# https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html
###############################################################################

resource "aws_acm_certificate" "server" {
  private_key       = file("${path.module}/../certs/server.key")
  certificate_body  = file("${path.module}/../certs/server.crt")
  certificate_chain = file("${path.module}/../certs/ca.crt")

  tags = {
    Name = "${var.project_name}-server-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "client_root" {
  private_key       = file("${path.module}/../certs/client1.domain.tld.key")
  certificate_body  = file("${path.module}/../certs/client1.domain.tld.crt")
  certificate_chain = file("${path.module}/../certs/ca.crt")

  tags = {
    Name = "${var.project_name}-client-root-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
