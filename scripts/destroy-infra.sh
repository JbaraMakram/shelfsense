#!/bin/bash
# destroy-infra.sh — Destroy all AWS infrastructure when not in use
# To rebuild: push to GitHub, Jenkins pipeline runs terraform apply automatically

set -e

echo "================================================"
echo " ShelfSense — Destroy AWS Infrastructure"
echo " WARNING: This deletes all EC2 instances and data"
echo "================================================"

read -p "Are you sure? Type 'yes' to confirm: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

cd "$(dirname "$0")/../infra/terraform"

terraform destroy -auto-approve -var="my_ip=$(curl -s https://checkip.amazonaws.com)"

echo "================================================"
echo " All AWS resources destroyed."
echo " To rebuild: git push → Jenkins rebuilds everything"
echo "================================================"
