#!/usr/bin/env bash
# Provision the instance, then configure it.
set -euo pipefail

cd "$(dirname "$0")/.."

terraform -chdir=terraform init -input=false
terraform -chdir=terraform apply -auto-approve

( cd ansible && ansible-playbook -i inventory.ini playbook.yml )

IP="$(terraform -chdir=terraform output -raw instance_public_ip)"
echo
echo "Done. Server is at ${IP}:25565"
echo "Check it with: nmap -sV -Pn -p T:25565 ${IP}"
