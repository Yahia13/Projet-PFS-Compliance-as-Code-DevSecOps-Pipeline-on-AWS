output "jenkins_public_ip" {
  description = "L'adresse IP publique du serveur Jenkins"
  value       = aws_eip.instance_eip.public_ip
}

output "instance_id" {
  value = aws_instance.jenkins.id
}
output "jenkins_private_ip" {
  value       = aws_instance.jenkins.private_ip
  description = "Private IP of Jenkins instance"
}
