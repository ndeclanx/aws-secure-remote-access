output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.main.id
}

output "vpn_endpoint_dns" {
  description = "DNS name to use in your .ovpn client configuration"
  value       = aws_ec2_client_vpn_endpoint.main.dns_name
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "vpn_security_group_id" {
  description = "Security group ID of the VPN endpoint  -  reference this in other resource SGs"
  value       = aws_security_group.vpn_endpoint.id
}

output "internal_security_group_id" {
  description = "Security group ID for internal resources  -  attach to EC2, RDS, ECS"
  value       = aws_security_group.internal_resources.id
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group where VPN connection events are stored"
  value       = aws_cloudwatch_log_group.vpn.name
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT gateways  -  whitelist these on external services"
  value       = aws_eip.nat[*].public_ip
}
