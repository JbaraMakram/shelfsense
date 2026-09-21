# Future Improvements

Things I would add or change if I kept working on this past the course deadline.

**Move Jenkins off my laptop.** Right now it runs locally and needs ngrok to be reachable. A real setup would run Jenkins on its own server or use a hosted CI/CD service, so it's always available.

**Use feature branches.** I worked directly on `main` since this was solo work under a deadline. With a team, I would use feature branches and pull requests before merging.

**Add automated rollback.** Right now if a deploy fails the health check, the pipeline just fails. A better setup would automatically roll back to the previous working image.

**Keep infrastructure running, or automate teardown properly.** I destroy the EC2 servers between sessions to save cost, and Terraform rebuilds them on the next pipeline run. A cleaner version would use a scheduled job to spin resources up and down automatically, instead of doing it by hand.

**Add HTTPS.** The app currently runs over plain HTTP through nginx. Adding a TLS certificate would be a basic next step for anything closer to production.

**More tests.** Current tests cover the basics. I'd add more coverage, especially around the database and edge cases like adding an item with bad input.

**Secrets manager instead of GitHub Secrets / Jenkins store.** For a bigger setup, I'd move to something like AWS Secrets Manager, so all tools pull from one place instead of keeping separate copies.

**Alerts from Grafana.** Right now Grafana just shows dashboards. Adding alert rules (for example, if the app goes down) would make the monitoring actually useful day to day, not just visual.
