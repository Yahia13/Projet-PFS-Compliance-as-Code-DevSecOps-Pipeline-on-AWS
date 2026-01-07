output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "jenkins_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins_profile.name
}

output "ansible_manager_role_arn" {
  value = aws_iam_role.ansible_manager_role.arn
}
output "ansible_manager_instance_profile_name" {
  value = aws_iam_instance_profile.ansible_manager_profile.name
}
output "jenkins_role_arn" {
  value = aws_iam_role.jenkins_role.arn
}