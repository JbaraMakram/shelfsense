# Deployment Flow

What happens, step by step, from a `git push` to the app being live.

1. **Push to GitHub.** I push code to the repo.

2. **Webhook fires.** GitHub sends a push event to Jenkins through an ngrok tunnel (Jenkins runs locally on my laptop, so it needs a public URL to receive the webhook).

3. **Jenkins starts the pipeline.**
   - Checks out the code
   - Runs the tests
   - Builds the Docker image
   - Pushes the image to GHCR, tagged with the build number and `latest`

4. **Terraform Apply.** Jenkins runs `terraform apply`. If the servers already exist and nothing changed, this does nothing. If they were destroyed, it creates them again.

5. **Read Terraform outputs.** Jenkins reads the app server IP and DB server IP from Terraform, and writes them into the Ansible inventory file.

6. **Ansible deploy.** Jenkins runs the Ansible playbook against the app server. It installs Docker and nginx if missing, pulls the new image, and restarts the container with the new version.

7. **Health check.** Jenkins waits a few seconds, then calls `/health` on the app server. If it doesn't return 200, the pipeline fails.

8. **Done.** If everything passed, the app is live at the app server's public IP.

## Local run (no AWS)

The app can also run straight on my laptop with `python3 app.py`, without touching AWS at all. Useful for quick testing before pushing.

## Kubernetes run (no AWS)

Separately, the app can be deployed to a local minikube cluster using the Helm chart in `k8s/`. This path does not use Jenkins or AWS at all — it's a local demonstration of container orchestration.
