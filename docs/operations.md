# Shutting Down and Rebuilding

Notes for myself on stopping AWS costs and starting again later.

## Destroy the infrastructure

The real Terraform state lives inside the Jenkins container, not on my laptop. So destroy has to run from there.

1. Get my current IP:

```bash
curl -s https://checkip.amazonaws.com
```

2. Run destroy inside Jenkins, using its saved AWS keys:

```bash
docker exec -u root jenkins bash -c "cd /var/jenkins_home/workspace/shelfsense/infra/terraform && export AWS_ACCESS_KEY_ID=YOUR_KEY && export AWS_SECRET_ACCESS_KEY=YOUR_SECRET && terraform destroy -auto-approve -var='my_ip=<my current ip>'"
```

Replace `YOUR_KEY` and `YOUR_SECRET` with the real AWS keys. Never paste these anywhere outside my own terminal.

## My IP can change

Home internet IPs are not fixed. They can change between sessions.

**Before rebuilding, always check:**

```bash
curl -s https://checkip.amazonaws.com
```

**If it's the same as before** — nothing to do. Just click Build Now in Jenkins.

**If it's different** — update it in exactly one place:

1. Jenkins → Manage Jenkins → Credentials → System → Global credentials
2. Find credential `my-ip`
3. Click it → Update
4. Paste the new IP in the Secret field
5. Save

I do not need to touch GitHub Secrets, Terraform files, or anything else. Only this one Jenkins credential controls it.

## Rebuild

Once the IP is confirmed correct, go to Jenkins → shelfsense job → **Build Now**. This recreates the EC2 servers, deploys the database and app, and runs the health check — same as any normal pipeline run.
