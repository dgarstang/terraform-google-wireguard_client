locals {
  private_key = trim(file("${abspath("${path.module}/private.key")}), "\n")
}

resource "null_resource" "write_wireguard_config" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF | sudo tee /opt/homebrew/etc/wireguard/wg0.conf > /dev/null
[Interface]
PrivateKey = ${local.private_key}
Address = ${var.interface_address}
DNS = ${var.dns_server_address}

[Peer]
PublicKey = ${var.peer_public_key}
AllowedIPs = 10.138.0.0/20
Endpoint = ${var.peer_public_ip}:51820
PersistentKeepalive = 25
EOF

sudo /opt/homebrew/bin/wg-quick down wg0 || true
sudo /opt/homebrew/bin/wg-quick up wg0
EOT
  }
}

