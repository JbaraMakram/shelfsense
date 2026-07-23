# ShelfSense - Cloud Architecture

## Overview

ShelfSense runs on AWS using Free Tier resources.
Two EC2 instances are used — one for the application,
one for the database.
All infrastructure is provisioned with Terraform 
and configured with Ansible.

## AWS Services Used

| Service 		| Purpose 			| Why 			                         |
|-----------------------|-------------------------------|------------------------------------------------|
| EC2 app (t2.micro)    | Runs the Docker container     | Free Tier, enough for our app 		 |
| EC2 db (t2.micro)     | Runs PostgreSQL               | Separate from app for reliability 		 |
| VPC                   | Private network               | Isolates our resources from other AWS accounts |
| Public Subnet         | Both EC2s live here           | Need internet access 				 |
| Internet Gateway      | Connects VPC to internet      | Required for public access 			 |
| Security Group (app)  | Firewall for app server       | Controls who reaches the app 			 |
| Security Group (db)   | Firewall for db server        | Only app server can reach database 		 |
| Key Pair              | SSH access to both servers    | Secure admin login 				 |

## Network Design
Internet
    │
Internet Gateway
    │
VPC (10.0.0.0/16)
    │
Public Subnet (10.0.1.0/24)
    │
    ├── EC2-1: App Server (t2.micro) — Ubuntu 22.04
    │ └── Docker Container: shelfsense:latest
    │ ├── Flask app (port 5000)
    │ ├── /health (liveness)
    │ ├── /ready (readiness)
    │ └── /metrics (Prometheus)
    │
    └── EC2-2: Database Server (t2.micro) — Ubuntu 22.04
    └── PostgreSQL (port 5432)
    └── only reachable from EC2-1



## Security Group Rules
### App Server
| Type 	 | Port | Source       | Reason                   |
|--------|------|--------------|--------------------------|
| SSH 	 | 22   | Your IP only | Admin access             |
| HTTP   | 80   | 0.0.0.0/0    | App access from internet |
| Custom | 5000 | 0.0.0.0/0    | Flask direct access      |

### Database Server
| Type       | Port | Source             | Reason                           |
|------------|------|--------------------|----------------------------------|
| SSH        | 22   | Your IP only       | Admin access                     |
| PostgreSQL | 5432 | App Server SG only | Database only reachable from app |

## Design Decisions

**Why 2 EC2 instances?**
App and database on the same server means a single point of failure.
If the server goes down, both the app and the data are lost.
Separating them means the database stays running even if the app server has issues.

**Why not 3?**
A third EC2 would serve as a load balancer — distributing traffic across
multiple app servers. We only have one app server so a load balancer has
nothing to balance. Unnecessary complexity and cost for this project scale.

**Why t2.micro for both?**
Free Tier eligible — 750 hours/month each. ShelfSense is a small inventory
app. 1 vCPU and 1GB RAM is enough for both the app and the database at
this scale.

**Why Ubuntu 22.04?**
Same OS as our development machine. No environment differences between
development and production.

**Why public subnet for the database?**
A private subnet requires a NAT Gateway which costs money.
The database Security Group is locked to only accept connections from the
app server — so it is protected even in a public subnet.

## Full Pipeline Flow

git push
    │
GitHub webhook
    │
Jenkins (laptop)
    ├── pytest — run tests
    ├── docker build — build image
    ├── docker push — push to GitHub Registry
    └── ansible-playbook
    ├── EC2-1: pull image, restart container
    └── EC2-2: ensure PostgreSQL is running

