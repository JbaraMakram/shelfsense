# Lessons Learned

Things I understood better after actually building this, not just reading about it.

**Idempotency is not automatic.** I assumed my Ansible playbook was safe to run twice, since I used `state: present` in some places. But the docker container task used raw shell commands, which recreated the container every single run even when nothing changed. Switching to the proper `docker_container` module fixed this. Idempotency has to be built in on purpose, task by task.

**Networking problems don't look like networking problems.** When my app couldn't reach anything on AWS, the error looked like a random connection timeout. It took a while to realize the Docker bridge network was the real cause, not the app or the security group rules I kept checking.

**Jenkins needs its own copy of everything.** I expected Jenkins to use the tools already on my laptop. It doesn't — the Jenkins container needs Ansible, Terraform, Python, and Docker installed inside itself, separately.

**Local tools need public URLs to talk to GitHub.** Running Jenkins on my own laptop meant GitHub had no way to reach it for webhooks. ngrok solved this, but it also taught me that "local" and "reachable from the internet" are two different things, even on the same machine.

**Secrets live in more than one place.** GitHub Actions and Jenkins each need their own copy of credentials, stored their own way. I originally thought one GitHub Secret would cover everything.

**Documentation takes real time.** Writing docs, decisions, and this file took nearly as much effort as some of the infrastructure work. Worth it — but I underestimated it at the start.
