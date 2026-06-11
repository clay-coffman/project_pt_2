#!/usr/bin/env bash
# Tear everything down so we stop spending Learner Lab credit.
set -euo pipefail

cd "$(dirname "$0")/.."
terraform -chdir=terraform destroy -auto-approve
