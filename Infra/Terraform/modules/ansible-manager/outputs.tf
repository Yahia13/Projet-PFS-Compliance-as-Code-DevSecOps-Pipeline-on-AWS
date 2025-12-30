output "ansible_public_ip" {
  value = aws_instance.ansible_manager.public_ip
}