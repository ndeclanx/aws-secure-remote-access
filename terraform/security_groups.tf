###############################################################################
# VPN Endpoint Security Group
# Allows inbound from the internet on UDP 443 (OpenVPN)
# Restricts outbound to the VPC only
###############################################################################
resource "aws_security_group" "vpn_endpoint" {
  name        = "${var.project_name}-vpn-sg"
  description = "Controls inbound VPN client connections and outbound to VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "OpenVPN client connections"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow VPN traffic to reach the VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-vpn-sg"
  }
}

###############################################################################
# Internal Resources Security Group
# Only accepts connections originating from the VPN security group.
# Attach this to any EC2, RDS, or ECS resource that VPN users need to reach.
###############################################################################
resource "aws_security_group" "internal_resources" {
  name        = "${var.project_name}-internal-sg"
  description = "Allows inbound access only from authenticated VPN clients"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH  -  VPN clients only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_endpoint.id]
  }

  ingress {
    description     = "HTTPS  -  VPN clients only"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_endpoint.id]
  }

  ingress {
    description     = "HTTP  -  VPN clients only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_endpoint.id]
  }

  ingress {
    description     = "PostgreSQL  -  VPN clients only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_endpoint.id]
  }

  ingress {
    description     = "MySQL/Aurora  -  VPN clients only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_endpoint.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-internal-sg"
  }
}
