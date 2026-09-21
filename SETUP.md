# Setup Guide

This is for anyone who wants to run this project themselves, not just read the code.

You need your own AWS account, your own GitHub account, and your own computer with Docker installed. Nothing in this repo works with my credentials — you build your own copy from scratch.

## What you need before starting

- An AWS account (free tier is enough)
- A GitHub account
- Docker installed on your computer
- Terraform installed
- Ansible installed
- Git installed

## Step 1: Fork or clone the repo

```bash
git clone https://github.com/JbaraMakram/shelfsense.git
cd shelfsense
```

If you want your own GitHub webhook to work, fork it into your own account instead, then clone your fork.

## Step 2: Create an AWS key pair

This is the SSH key your EC2 servers will trust.

1. AWS Console → EC2 → Key Pairs → Create key pair
2. Name it anything, for example `my-shelfsense-key`
3. Download the `.pem` file
4. Move it somewhere safe, like `~/.ssh/`
5. Run: `chmod 400 ~/.ssh/my-shelfsense-key.pem`

## Step 3: Create an AWS IAM user

1. AWS Console → IAM → Users → Create user
2. Give it programmatic access
3. Attach policy `AmazonEC2FullAccess` (or a more limited custom one if you prefer)
4. Save the Access Key ID and Secret Access Key it gives you — shown once

## Step 4: Update Terraform variables

Open `infra/terraform/variables.tf` and check these values match what you want:

- `aws_region` — which AWS region to use
- `key_name` — the key pair name from Step 2
- `ami_id` — an Ubuntu 22.04 AMI ID for your chosen region

## Step 5: Get your own IP address

```bash
curl -s https://checkip.amazonaws.com
```

You'll need this in Step 9. It's used to lock down SSH access to only your computer.

## Step 6: Install Jenkins locally

```bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

Open `http://localhost:8080`, follow the setup wizard, install the suggested plugins.

## Step 7: Give Jenkins permission to use Docker

```bash
stat -c '%g' /var/run/docker.sock
```

Note the number it gives you. Then:

```bash
docker exec -u root jenkins groupmod -g <that number> docker
docker restart jenkins
```

## Step 8: Create a GitHub token for the container registry

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Check the box `write:packages`
4. Copy the token — shown once

## Step 9: Add credentials inside Jenkins

Manage Jenkins → Credentials → System → Global credentials → Add Credentials, four times:

| Kind | ID | Value |
|---|---|---|
| Username with password | `aws-credentials` | your AWS Access Key ID and Secret |
| Username with password | `github-registry` | your GitHub username and the token from Step 8 |
| SSH Username with private key | `shelfsense-ssh-key` | paste the contents of your `.pem` file |
| Secret text | `my-ip` | your IP from Step 5 |

## Step 10: Install ngrok and expose Jenkins

```bash
ngrok http 8080
```

Copy the `https://...ngrok-free.app` (or `.dev`) URL it gives you. This changes every time you restart ngrok on the free plan, so keep it running.

## Step 11: Create the Jenkins job

1. Jenkins → New Item → Pipeline
2. Name it `shelfsense`
3. Under Pipeline, choose "Pipeline script from SCM"
4. SCM: Git
5. Repository URL: your fork's URL
6. Script Path: `ci-cd/Jenkinsfile`
7. Under Build Triggers, check "GitHub hook trigger for GITScm polling"
8. Save

## Step 12: Add the GitHub webhook

1. Your GitHub repo → Settings → Webhooks → Add webhook
2. Payload URL: your ngrok URL + `/github-webhook/`
3. Content type: `application/json`
4. Events: just the push event
5. Add webhook

## Step 13: Run it

In Jenkins, click **Build Now** on the shelfsense job.

This will:
- Build and test the app
- Push the image to your GHCR
- Create your own EC2 servers with Terraform
- Deploy the app and database with Ansible
- Check that it's healthy

First run takes a few minutes, since it's creating real servers. Once it's green, the app is live at the app server's IP, shown at the end of the pipeline log.

## If your IP changes

Home internet IPs change sometimes. If Terraform or SSH steps start failing with a timeout, check your current IP again:

```bash
curl -s https://checkip.amazonaws.com
```

If it's different, update the `my-ip` credential in Jenkins to the new value.

## Shutting down

To avoid AWS charges, destroy the servers when you're done testing:

```bash
cd infra/terraform
terraform destroy -auto-approve -var="my_ip=<your ip>"
```

Run this with your own AWS keys set as environment variables, or through Jenkins directly.
