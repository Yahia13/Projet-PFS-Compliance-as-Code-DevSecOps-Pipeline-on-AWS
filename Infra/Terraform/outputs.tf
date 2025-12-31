# Pour l'interface Web (Navigateur)
output "jenkins_public_ip" {
  value = aws_eip.instance_eip.public_ip
}

# Pour Ansible (Communication interne)
output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}