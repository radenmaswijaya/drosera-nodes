#!/bin/bash

echo "======================================"
echo "          MAS GIBRAN GANTENG"
echo "======================================"

# Cek .env
if [ ! -f .env ]; then
  echo ""
  echo "[INFO] .env tidak ditemukan. Silakan isi data berikut:"
  read -p "Masukkan PRIVATE_KEY (0x...): " PRIVATE_KEY
  read -p "Masukkan EMAIL GitHub Anda: " GITHUB_EMAIL
  read -p "Masukkan USERNAME GitHub Anda: " GITHUB_USERNAME
  read -p "Masukkan Alamat Node Operator Anda: " NODE_OPERATOR

  echo "PRIVATE_KEY=$PRIVATE_KEY
EMAIL=$GITHUB_EMAIL
USERNAME=$GITHUB_USERNAME
OPERATOR=$NODE_OPERATOR" > .env
  echo "[INFO] File .env berhasil dibuat."
fi

# Load isi .env
export $(grep -v '^#' .env | xargs)

# Validasi PRIVATE_KEY
if [[ ! "$PRIVATE_KEY" =~ ^0x[a-fA-F0-9]{64}$ ]]; then
  echo "[ERROR] Private key tidak valid. Harus diawali 0x dan 64 karakter hex."
  exit 1
fi

# Install dependensi
apt update && apt install -y curl git unzip

# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc || true
foundryup

# Install Bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc || true

# Clone project
mkdir -p /root/my-drosera-node
git clone https://github.com/$USERNAME/drosera-node-raden.git /root/my-drosera-node || true
cd /root/my-drosera-node || exit 1

# Inisialisasi proyek Bun jika belum
[ ! -f package.json ] && bun init -y
bun install

# Simpan systemd service
cat <<EOF > /etc/systemd/system/drosera.service
[Unit]
Description=Drosera Node Raden
After=network.target

[Service]
User=root
WorkingDirectory=/root/my-drosera-node
ExecStart=/root/.bun/bin/bun deploy-trap.ts
Restart=always
RestartSec=5
Environment=NODE_ENV=production
EnvironmentFile=/root/my-drosera-node/.env

[Install]
WantedBy=multi-user.target
EOF

# Aktifkan service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable drosera
systemctl restart drosera

echo ""
echo "======================================"
echo "        INSTALL SELESAI"
echo " TRAP TERDEPLOY DI /my-drosera-node"
echo "   KUNJUNGI https://app.drosera.io/"
echo "======================================"
