# Recherche de la dernière image Ubuntu (AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
# Instance EC2 pour Ansible
resource "aws_instance" "ansible_manager" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro" # Petite instance suffit pour Ansible
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Script pour installer Ansible automatiquement au démarrage
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y software-properties-common
              add-apt-repository --yes --update ppa:ansible/ansible
              apt-get install -y ansible git
              EOF

  tags = { Name = "${var.project_name}-ansible-manager" }
}