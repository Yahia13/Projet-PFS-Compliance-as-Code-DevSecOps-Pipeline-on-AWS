output "jenkins_public_ip" {
  value       = module.jenkins_ec2.jenkins_public_ip
  description = "Public IP of Jenkins (from module)"
}

output "jenkins_private_ip" {
  value       = module.jenkins_ec2.jenkins_private_ip
  description = "Private IP of Jenkins (from module)"
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