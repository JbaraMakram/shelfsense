# Design Decisions

Choices I made in this project, and why.

## Port 5433 for local Postgres testing

I run more than one project on this laptop that uses Postgres (Shield, DesignFlow). Default port 5432 kept clashing between them. I use 5433 for ShelfSense's local Postgres so they don't fight over the same port.

## `--network host` for the app container

At first I ran the container on Docker's default bridge network. Traffic from the container was going out with the bridge's internal IP, and AWS security groups blocked it. Switching to `--network host` makes the traffic look like it's coming from the EC2 instance itself, which the security group already allows.

## nginx reverse proxy on port 80

Browsers and some networks block direct access to port 5000. Putting nginx in front, listening on port 80 and forwarding to 5000, avoids that problem and matches how a real production app would be set up.

## Two separate EC2 servers (app + DB)

I could have run both on one server. I split them because that's closer to a real setup, and it was part of what the course wanted to see — knowing how to manage more than one server with Terraform and Ansible together.

## DB reached by private IP, not public IP

The app connects to the database using its private IP. Public IP would work too, but it means the traffic leaves AWS's internal network for no reason, and it's slower and less secure.

## Namespace `default` in Kubernetes

For this project's scale, one namespace is enough. A dedicated namespace would matter more with multiple environments or teams sharing a cluster. Keeping it simple here was a deliberate choice, not something I skipped.

## `replicas: 2` in the Helm chart

Two replicas is the minimum needed to actually demonstrate that Kubernetes can load-balance and survive one pod going down, without wasting resources on a laptop-based minikube cluster.

## Image tagging: build number + latest

Every image is tagged with the Jenkins build number, so I can always trace exactly which build is running. `latest` is also pushed for convenience when testing manually.

## Helm release name

The release is named after the app (`shelfsense`), matching the chart name, so there's no confusion about what a `helm list` output refers to.

## Branching strategy

I worked directly on `main` for this project. It's a solo project with no team to coordinate branches with, and course deadlines meant speed mattered more than a full branching model. In a team setting, I would use feature branches and pull requests before merging to `main`.

## Terraform apply on every pipeline run

Terraform is idempotent — running `apply` when nothing changed does nothing. So instead of applying once and hoping the servers stay up, the pipeline applies every run. If the servers were destroyed (which I do between sessions to save AWS cost), the pipeline rebuilds them automatically.

## Credentials

No credentials are hardcoded anywhere in the code. AWS keys, the SSH key, and the registry token are stored in GitHub Secrets and in the Jenkins Credentials Store, never in a file that gets committed.
