resource "aws_ssm_parameter" "ansible_ssh_key" {
  name        = "/pfs/ansible/ssh_key"
  description = "SSH private key for Ansible Manager"
  type        = "SecureString"
  value       = var.ansible_ssh_private_key_pem
}
