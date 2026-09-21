# Folder Structure

A quick guide to what's where in this repo.

```
shelfsense/
├── app/                    Flask application code
│   ├── app.py              Main app file, all routes
│   ├── requirements.txt    Python dependencies
│   ├── templates/          HTML pages
│   └── logs/                JSON log output (not committed)
│
├── docker/
│   └── Dockerfile          Builds the app image
│
├── infra/
│   ├── terraform/          Creates the AWS EC2 servers
│   └── ansible/            Configures servers and deploys the app
│       └── deploy-app.yml  Main deployment playbook
│
├── ci-cd/
│   └── Jenkinsfile         The full CI/CD pipeline
│
├── k8s/                    Kubernetes manifests and Helm chart
│
├── docs/                   This folder — architecture, decisions, notes
│   └── screenshots/        Proof of working pipeline, dashboards, etc.
│
└── README.md
```

## Why this layout

Each tool gets its own folder (`infra/`, `ci-cd/`, `k8s/`), so it's clear what belongs to what. `app/` is kept separate from infrastructure code, so the app itself has no idea it's running on AWS, Kubernetes, or anywhere else. `docs/` holds everything that explains the project instead of running it.
