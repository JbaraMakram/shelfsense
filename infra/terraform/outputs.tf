output "app_server_ip" {
  description = "Public IP of the app server — use this to SSH and access the app"
  value       = aws_instance.shelfsense_app.public_ip
}

output "db_server_ip" {
  description = "Public IP of the DB server — use this to SSH for admin"
  value       = aws_instance.shelfsense_db.public_ip
}

output "app_url" {
  description = "ShelfSense app URL"
  value       = "http://${aws_instance.shelfsense_app.public_ip}:5000"
}

output "db_server_private_ip" {
  description = "Private IP of the DB server — used for internal VPC communication"
  value       = aws_instance.shelfsense_db.private_ip
}
