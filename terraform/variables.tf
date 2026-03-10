variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
  default     = "secure-remote-access"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets  -  one per availability zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets  -  used for NAT gateways"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to deploy subnets into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpn_client_cidr" {
  description = "CIDR block assigned to VPN clients  -  must not overlap with vpc_cidr"
  type        = string
  default     = "10.100.0.0/16"
}

variable "split_tunnel_enabled" {
  description = "When true, only AWS-bound traffic routes through the VPN"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "DNS servers pushed to connected VPN clients"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "vpn_log_retention_days" {
  description = "Number of days to retain VPN connection logs in CloudWatch"
  type        = number
  default     = 30
}
