output "public_ip" {
  description = "L'adresse IP publique du serveur Jenkins"
  value       = aws_eip.instance_eip.public_ip
}

output "instance_id" {
  value = aws_instance.jenkins.id
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