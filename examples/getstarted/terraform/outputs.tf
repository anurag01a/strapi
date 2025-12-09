output "public_ip" {
  description = "Public IP of the Strapi Server"
  value       = aws_instance.strapi.public_ip
}

output "strapi_url" {
  description = "URL to access Strapi"
  value       = "http://${aws_instance.strapi.public_ip}:1337"
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.strapi.public_ip}"
}
