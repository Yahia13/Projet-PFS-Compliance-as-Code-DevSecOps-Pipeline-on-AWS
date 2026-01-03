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
  iam_instance_profile = var.instance_profile_name
  user_data = templatefile("${path.module}/userdata.sh", {
  ansible_bucket_name = var.ansible_files_bucket_name
})


  tags = { Name = "${var.project_name}-ansible-manager" }
}