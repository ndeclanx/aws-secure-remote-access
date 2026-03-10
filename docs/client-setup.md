# Client Setup Guide

This guide walks an end user through connecting to the AWS Client VPN.

---

## Prerequisites

- OpenVPN client installed: [Download here](https://openvpn.net/vpn-client/)
- Your `.ovpn` configuration file (provided by your administrator)
- Your client certificate and private key (provided by your administrator)

---

## Step 1  -  Download the Base Configuration

After `terraform apply` completes, your administrator downloads the base `.ovpn` file from:

**AWS Console → EC2 → Client VPN Endpoints → [endpoint] → Download Client Configuration**

---

## Step 2  -  Append Your Certificate

The downloaded config does not include your client certificate. Append it:

```bash
# Replace paths with your actual cert/key file locations
cat >> your-config.ovpn <<EOF

<cert>
$(cat client1.domain.tld.crt)
</cert>

<key>
$(cat client1.domain.tld.key)
</key>
EOF
```

---

## Step 3  -  Import into OpenVPN Client

1. Open the OpenVPN Connect app
2. Click **+** → **Import from file**
3. Select your modified `.ovpn` file
4. Click **Add**

---

## Step 4  -  Connect

Toggle the connection on. You should see a green connected indicator.

To verify connectivity, run:

```bash
# Ping a private resource IP (ask your admin for a valid IP)
ping 10.0.1.x

# Or test SSH access
ssh -i your-key.pem ec2-user@10.0.1.x
```

---

## Troubleshooting

| Issue | Likely Cause | Fix |
|---|---|---|
| Connection times out | UDP 443 blocked on your network | Ask admin to try TCP mode |
| Certificate error | Wrong cert appended to .ovpn | Re-export and re-append correctly |
| Connected but can't reach resources | Authorization rule not set for your group | Contact admin |
| Slow performance | Split tunnel disabled | Ask admin to enable split tunnel |

---

## Security Reminders

- **Never share your `.key` file.** It is your private credential.
- **Disconnect when not in use.** Do not leave VPN running 24/7 on untrusted networks.
- **Report unusual behaviour.** If you see unexpected access prompts or disconnections, tell your administrator immediately.
