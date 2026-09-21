# ShelfSense

ShelfSense is a simple inventory management app for small warehouses. You can track items, quantity, location, and category, and see which items are low on stock.

This project was built as my final project for a DevOps course. The goal was not just to build an app, but to show the full DevOps flow: infrastructure as code, CI/CD, containers, orchestration, and monitoring, all working together.

## What it does

- Dashboard showing total items and low stock warnings
- Add, view, and delete items
- Health and readiness endpoints for monitoring
- Metrics endpoint for Prometheus

## Tech stack

- **App:** Flask, SQLAlchemy, PostgreSQL
- **Containers:** Docker, GitHub Container Registry (GHCR)
- **Infrastructure:** Terraform, AWS EC2 (eu-north-1)
- **Configuration:** Ansible
- **CI/CD:** Jenkins
- **Orchestration:** Kubernetes (minikube) with Helm
- **Monitoring:** Prometheus and Grafana

## How it works

1. Code is pushed to GitHub
2. A webhook triggers Jenkins automatically
3. Jenkins runs the tests
4. Jenkins builds a Docker image and pushes it to GHCR
5. Jenkins runs Terraform to make sure the AWS servers exist
6. Jenkins runs Ansible to deploy the new image to the app server
7. Jenkins checks the `/health` endpoint to confirm the app is up

Two EC2 servers are used: one for the app, one for the database. Both are t3.micro on Ubuntu 22.04.

## Running it locally

```bash
cd app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

App runs on `http://localhost:5000`.

## Project structure

```
app/            Flask application
docker/         Dockerfile
infra/
  terraform/    AWS infrastructure (EC2, networking)
  ansible/      Server setup and deployment
ci-cd/          Jenkinsfile
k8s/            Kubernetes manifests and Helm chart
docs/           Architecture notes, decisions, screenshots
```

## Credentials and secrets

No credentials are stored in this repo. Everything needed to run the pipeline is kept outside the code:

- **GitHub Secrets** hold the AWS keys, GHCR token, and SSH key used by GitHub Actions.
- **Jenkins Credentials Store** holds the same type of values, used only inside Jenkins, since Jenkins runs locally and does not read GitHub Secrets.

If you want to run this project yourself, you need to add your own values in both places. Nothing will work with values copied from this README, because there are none here.

## Monitoring

The app exposes a `/metrics` endpoint in Prometheus format. Prometheus scrapes it, and Grafana shows the dashboards. Logs are written in JSON format so they are easy to search and read.

## Notes

This project is run on a personal laptop with AWS free-tier resources, so infrastructure is destroyed between work sessions to avoid extra cost. `docs/` has more detail on design decisions, lessons learned, and what I would improve if I kept building this further.
