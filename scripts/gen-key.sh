#!/usr/bin/env bash
# One-time: make the SSH keypair Terraform uploads and Ansible connects with.
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p keys

if [ -f keys/minecraft-key ]; then
  echo "keys/minecraft-key already exists, leaving it alone"
  exit 0
fi

ssh-keygen -t rsa -b 4096 -N "" -f keys/minecraft-key -C "cs312-minecraft"
echo "wrote keys/minecraft-key and keys/minecraft-key.pub"
