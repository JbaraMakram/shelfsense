#!/bin/bash
# Reads EC2 IP from Terraform and generates prometheus.yml

APP_IP=$(cd ../infra/terraform && terraform output -raw app_server_ip)

cat > prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'shelfsense-production'
    static_configs:
      - targets: ['${APP_IP}:5000']
    metrics_path: '/metrics'

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

echo "Generated prometheus.yml with app IP: ${APP_IP}"
