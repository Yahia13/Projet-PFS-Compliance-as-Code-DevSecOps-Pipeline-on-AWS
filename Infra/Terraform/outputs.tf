# Pour l'interface Web (Navigateur)
output "jenkins_public_ip" {
  value = aws_eip.instance_eip.public_ip
}

# Pour Ansible (Communication interne)
output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}

# -------------------------
# Security Group outputs
# -------------------------
output "jenkins_sg_id" {
  value       = aws_security_group.jenkins_sg.id
  description = "Security Group ID for Jenkins EC2"
}

output "ansible_sg_id" {
  value       = aws_security_group.ansible_sg.id
  description = "Security Group ID for Ansible Manager EC2"
}

output "eks_cluster_sg_id" {
  value       = aws_security_group.eks_cluster_sg.id
  description = "Security Group ID for EKS control plane"
}

output "eks_nodes_sg_id" {
  value       = aws_security_group.eks_nodes_sg.id
  description = "Security Group ID for EKS worker nodes"
}