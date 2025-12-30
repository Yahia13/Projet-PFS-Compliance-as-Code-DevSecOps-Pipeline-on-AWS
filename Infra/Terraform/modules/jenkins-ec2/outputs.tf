output "public_ip" {
  description = "L'adresse IP publique du serveur Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "instance_id" {
  value = aws_instance.jenkins.id
}