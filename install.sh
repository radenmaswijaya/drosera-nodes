#!/bin/bash

# Install bun kalau belum ada
if ! command -v bun &> /dev/null
then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Clone repo
cd ~
git clone https://github.com/radenmaswijaya/drosera-nodes.git
cd drosera-nodes

# Install dep
bun install

# Copy systemd service
cat <<EOF > /etc/systemd/system/drosera.service
[Unit]
Description=Drosera Node Raden
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/drosera-nodes
ExecStart=/root/.bun/bin/bun run start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable drosera.service
systemctl start drosera.service
