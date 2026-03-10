#!/usr/bin/env bash
# generate-certs.sh
#
# Generates server and client certificates for AWS Client VPN mutual TLS auth.
# Uses easy-rsa (the same PKI tooling used by OpenVPN).
#
# Usage:
#   chmod +x generate-certs.sh
#   ./generate-certs.sh
#
# Output: ../certs/ directory with ca.crt, server.crt/key, client.crt/key
#
# Requirements: curl, tar (Linux/macOS/WSL)

set -euo pipefail

EASY_RSA_VERSION="3.1.7"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${WORK_DIR}/../certs"
EASYRSA_DIR="${WORK_DIR}/EasyRSA-${EASY_RSA_VERSION}"

echo "============================================================"
echo " AWS Client VPN  -  Certificate Generator"
echo " Using easy-rsa v${EASY_RSA_VERSION}"
echo "============================================================"

# ── Download easy-rsa if not present ─────────────────────────────────────────
if [ ! -d "${EASYRSA_DIR}" ]; then
  echo ""
  echo "==> Downloading easy-rsa v${EASY_RSA_VERSION}..."
  curl -fsSL \
    "https://github.com/OpenVPN/easy-rsa/releases/download/v${EASY_RSA_VERSION}/EasyRSA-${EASY_RSA_VERSION}.tgz" \
    -o "EasyRSA-${EASY_RSA_VERSION}.tgz"
  tar xzf "EasyRSA-${EASY_RSA_VERSION}.tgz" -C "${WORK_DIR}"
  rm "EasyRSA-${EASY_RSA_VERSION}.tgz"
  echo "    Done."
fi

cd "${EASYRSA_DIR}"

# ── Initialise PKI ────────────────────────────────────────────────────────────
echo ""
echo "==> Initialising PKI directory..."
./easyrsa init-pki

# ── Build Certificate Authority ───────────────────────────────────────────────
echo ""
echo "==> Building Certificate Authority (CA)..."
echo "    (You will be prompted for a CA name  -  press Enter to use the default)"
./easyrsa build-ca nopass

# ── Generate Server Certificate ───────────────────────────────────────────────
echo ""
echo "==> Generating server certificate..."
./easyrsa --san="DNS:server" build-server-full server nopass

# ── Generate Client Certificate ───────────────────────────────────────────────
echo ""
echo "==> Generating client certificate..."
./easyrsa build-client-full client1.domain.tld nopass

# ── Copy Certificates to certs/ ───────────────────────────────────────────────
echo ""
echo "==> Copying certificates to ${CERTS_DIR}..."
mkdir -p "${CERTS_DIR}"

cp pki/ca.crt                             "${CERTS_DIR}/ca.crt"
cp pki/issued/server.crt                  "${CERTS_DIR}/server.crt"
cp pki/private/server.key                 "${CERTS_DIR}/server.key"
cp pki/issued/client1.domain.tld.crt      "${CERTS_DIR}/client1.domain.tld.crt"
cp pki/private/client1.domain.tld.key     "${CERTS_DIR}/client1.domain.tld.key"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Certificates generated successfully:"
echo ""
echo "   ${CERTS_DIR}/ca.crt                        (CA certificate)"
echo "   ${CERTS_DIR}/server.crt                     (Server certificate)"
echo "   ${CERTS_DIR}/server.key                     (Server private key)"
echo "   ${CERTS_DIR}/client1.domain.tld.crt         (Client certificate)"
echo "   ${CERTS_DIR}/client1.domain.tld.key         (Client private key)"
echo ""
echo " Next steps:"
echo "   1. cd ../terraform"
echo "   2. terraform init"
echo "   3. terraform plan"
echo "   4. terraform apply"
echo ""
echo " ⚠  NEVER commit the certs/ directory to git."
echo "    Store client keys in a secrets manager for team distribution."
echo "============================================================"
