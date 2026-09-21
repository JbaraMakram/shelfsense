#!/bin/bash
# build-infra.sh — Build AWS infrastructure manually (without Jenkins)
# Normally Jenkins handles this automatically on git push

set -e

echo "================================================"
echo " ShelfSense — Build AWS Infrastructure"
echo "================================================"

cd "$(dirname "$0")/../infra/terraform"

terraform init -input=false
terraform apply -auto-approve -var="my_ip=$(curl -s https://checkip.amazonaws.com)"

echo "================================================"
echo " Infrastructure ready."
echo " App URL: $(terraform output app_url)"
echo " Now run Jenkins pipeline to deploy the app."
echo "================================================"
