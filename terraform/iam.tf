###############################################################################
# IAM  -  CloudWatch logging permissions for the VPN service
###############################################################################
resource "aws_iam_role" "vpn_logging" {
  name        = "${var.project_name}-vpn-logging-role"
  description = "Allows the Client VPN service to write connection logs to CloudWatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowClientVPNAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "vpn_cloudwatch" {
  name        = "${var.project_name}-vpn-cloudwatch-policy"
  description = "Minimum permissions for VPN connection log delivery to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowVPNLogDelivery"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/vpn/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpn_cloudwatch" {
  role       = aws_iam_role.vpn_logging.name
  policy_arn = aws_iam_policy.vpn_cloudwatch.arn
}
