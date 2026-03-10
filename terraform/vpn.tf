###############################################################################
# CloudWatch Log Group  -  all VPN connection events are recorded here
###############################################################################
resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/vpn/${var.project_name}"
  retention_in_days = var.vpn_log_retention_days

  tags = {
    Name = "${var.project_name}-vpn-logs"
  }
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "vpn-connections"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

###############################################################################
# Client VPN Endpoint
###############################################################################
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "${var.project_name} Client VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.vpn_client_cidr
  split_tunnel           = var.split_tunnel_enabled
  transport_protocol     = "udp" # UDP is faster; use "tcp" if UDP is blocked

  # Mutual TLS  -  both client and server present certificates
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_root.arn
  }

  # Every connection event is logged  -  who connected, when, from where
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }

  dns_servers = var.dns_servers

  tags = {
    Name = "${var.project_name}-vpn-endpoint"
  }
}

###############################################################################
# Network Associations  -  attach the VPN endpoint to each private subnet
###############################################################################
resource "aws_ec2_client_vpn_network_association" "main" {
  count                  = length(var.private_subnet_cidrs)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.private[count.index].id
  security_groups        = [aws_security_group.vpn_endpoint.id]
}

###############################################################################
# Authorization Rules  -  scope what VPN clients can reach
# Adjust these per team or CIDR to enforce least-privilege access
###############################################################################
resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
  description            = "Allow authenticated VPN clients to reach the VPC"
}

###############################################################################
# Routes  -  push private subnet routes to connected clients
###############################################################################
resource "aws_ec2_client_vpn_route" "private" {
  count                  = length(var.private_subnet_cidrs)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = var.private_subnet_cidrs[count.index]
  target_vpc_subnet_id   = aws_subnet.private[count.index].id
  description            = "Route to private subnet ${count.index + 1}"

  depends_on = [aws_ec2_client_vpn_network_association.main]
}
