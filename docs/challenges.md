# Challenges

Problems I hit while building this, and how I solved them.

**App couldn't reach the database over AWS's network.** Turned out AWS security groups were blocking traffic from Docker's default bridge network, because the traffic came from the bridge's internal IP, not the EC2 instance's IP. Fixed by running the container with `--network host`.

**Port 5000 blocked in the browser.** Some networks and browsers refuse direct connections to port 5000. Added an nginx reverse proxy listening on port 80, forwarding to the app on 5000.

**Ansible playbook wasn't actually idempotent.** The container deploy step used raw `docker run` / `docker rm` shell commands, so every run tore down and rebuilt the container, even with no changes. Replaced it with Ansible's `community.docker.docker_container` module, which only changes things when needed.

**Database tables were never created.** A task to initialize the database tables was sitting under `handlers:` in the Ansible playbook, but nothing was notifying it, so it silently never ran. Moved it into `tasks:` so it actually executes on deploy.

**Jenkins couldn't reach GitHub webhooks.** Jenkins runs locally on my laptop, with no public address. Set up ngrok to expose `localhost:8080` publicly, and pointed the GitHub webhook at that address.

**Running out of AWS free-tier budget.** To avoid extra charges, I destroy the EC2 servers between work sessions. This meant the Terraform Apply stage in Jenkins had to run on every pipeline execution, not just once, so the servers get rebuilt automatically when I resume work.

**Postgres port conflicts on my own laptop.** I run other projects locally that also use Postgres on the default port. Changed ShelfSense's local Postgres port to 5433 to stop them clashing.
