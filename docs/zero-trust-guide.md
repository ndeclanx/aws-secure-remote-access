# Zero Trust Network Access  -  Design Guide

This document explains the zero trust principles applied in this architecture and how each control maps to NIST SP 800-207 (Zero Trust Architecture).

---

## What Is Zero Trust?

Zero Trust is a security model built on one principle: **never trust, always verify.**

Traditional VPN grants network-level trust after a single authentication event. Once connected, a user can typically reach anything in the network. Zero Trust replaces that model with:

- Authentication per resource, not per network
- Authorisation scoped to the minimum required access
- Continuous verification  -  trust is not permanent
- Full audit logging of every access event

---

## How This Architecture Applies Zero Trust

### 1. Verify Explicitly  -  Mutual TLS

Both the client and the server present certificates before a connection is established. This eliminates:

- Password-based attacks (no passwords exist)
- Credential stuffing (certificates cannot be guessed)
- Man-in-the-middle attacks (both sides are cryptographically verified)

**Implementation:** `acm.tf`  -  server and client certificates imported into ACM, referenced in the VPN endpoint authentication block.

---

### 2. Least Privilege Access  -  Authorization Rules

VPN clients are not granted blanket VPC access. Authorization rules scope which CIDR blocks each group can reach.

To restrict a team to a single subnet:

```hcl
# Example: Grant the dev team access to dev subnet only
resource "aws_ec2_client_vpn_authorization_rule" "dev_team" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = "10.0.1.0/24"   # dev subnet only
  access_group_id        = "dev-group-id"   # Active Directory group
  authorize_all_groups   = false
}
```

**Implementation:** `vpn.tf`  -  `aws_ec2_client_vpn_authorization_rule` resources.

---

### 3. Never Trust the Network  -  No Public IPs on Resources

Private resources (EC2, RDS, ECS) have no public IP addresses and live in private subnets with no direct internet route. The only path in is through the VPN endpoint.

Even if an attacker discovers a resource's private IP, it is unreachable without a valid client certificate.

**Implementation:** `vpc.tf`  -  private subnets have no `map_public_ip_on_launch`. Resources use the `internal_resources` security group which only allows inbound from the VPN security group.

---

### 4. Assume Breach  -  Full Connection Logging

Every VPN connection event  -  connection, disconnection, failed auth  -  is logged to CloudWatch with:

- Timestamp
- Client IP address
- Username (if using directory auth)
- Connection duration
- Bytes transferred

This means anomalous behaviour (off-hours access, unusual source IPs, excessive data transfer) is detectable.

**Implementation:** `vpn.tf`  -  `connection_log_options` block on the VPN endpoint.

---

### 5. Limit Blast Radius  -  Security Group Segmentation

The `internal_resources` security group only accepts traffic from the `vpn_endpoint` security group  -  not from any IP CIDR. This means:

- A compromised instance inside the VPC cannot reach other internal resources unless it is in the VPN security group
- Lateral movement is constrained by the security group boundary

**Implementation:** `security_groups.tf`  -  ingress rules reference `security_groups = [aws_security_group.vpn_endpoint.id]` not `cidr_blocks`.

---

### 6. Split Tunneling

With `split_tunnel = true`, only traffic destined for the VPC CIDR routes through the VPN. All other traffic (internet browsing, SaaS tools) exits directly from the client's local network.

Benefits:
- Reduced VPN bandwidth (no unnecessary traffic)
- Better performance for end users
- VPN not a single point of failure for all user internet access

Trade-off: If you need to enforce all traffic through a proxy or firewall, set `split_tunnel = false`.

---

## NIST SP 800-207 Mapping

| NIST Requirement | Implementation |
|---|---|
| All data sources treated as resources | Private subnets, no public IPs |
| All communication secured regardless of location | Mutual TLS on all VPN connections |
| Access per-session, not per-network | Authorization rules per CIDR/group |
| Access determined by dynamic policy | Security group rules enforced by AWS |
| All asset integrity monitored | CloudWatch connection logs |
| Authentication and authorisation strictly enforced | Certificate auth + SG-based ingress |

---

## Extending to Full ZTNA

This architecture provides strong foundational zero trust controls. For a full ZTNA implementation, consider adding:

| Addition | Tool |
|---|---|
| Identity-aware proxy | AWS Verified Access |
| Per-application access control | AWS IAM Identity Center |
| Device posture checks | AWS Systems Manager Fleet Manager |
| Continuous risk scoring | Amazon GuardDuty |
| Centralised certificate management | AWS Private CA |
