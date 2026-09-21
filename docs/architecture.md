# Architecture

This is how ShelfSense is put together.

## Overview

```
GitHub  --push-->  Jenkins  --build & push image-->  GHCR
                       |
                       v
                  Terraform (creates EC2 servers)
                       |
                       v
                  Ansible (deploys app to servers)
                       |
                       v
        App server (EC2) <---> DB server (EC2)
                       |
                       v
              Prometheus + Grafana (monitoring)
```

## Pieces

**GitHub** holds the code. A webhook tells Jenkins when something new is pushed.

**Jenkins** runs the pipeline. It tests the code, builds a Docker image, pushes it to GHCR, makes sure the AWS servers exist (Terraform), and deploys the new image (Ansible).

**GHCR** (GitHub Container Registry) stores the Docker images.

**Terraform** creates two EC2 servers in AWS, region eu-north-1. Both are t3.micro on Ubuntu 22.04. One is the app server, one is the database server.

**Ansible** configures the app server: installs Docker, sets up nginx as a reverse proxy, and runs the app container.

**App server** runs the Flask app inside Docker, using `--network host` so it can reach AWS resources properly. Nginx sits in front of it on port 80.

**DB server** runs PostgreSQL. The app connects to it using its private IP, not the public IP.

**Prometheus** scrapes the app's `/metrics` endpoint. **Grafana** shows the data as dashboards.

**Kubernetes (minikube) + Helm** is a second way the app is run, for the container orchestration part of the course. It runs locally, separate from the AWS EC2 setup.

## Why two EC2 servers

Splitting app and database onto separate servers is closer to how real production setups work, and it was a course requirement to show this separation.
