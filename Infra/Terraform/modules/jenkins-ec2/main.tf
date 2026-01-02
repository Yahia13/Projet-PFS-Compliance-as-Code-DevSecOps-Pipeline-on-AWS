
# 2. Recherche de la dernière image Ubuntu (AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 3. L'instance EC2 Jenkins
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.instance_profile_name
  key_name                    = var.key_name

  private_ip = "10.0.1.100"

  root_block_device {
    volume_size = 20 # 20 Go suffisent pour commencer
  }

  tags = { Name = "${var.project_name}-jenkins-server" }
}

resource "aws_eip" "instance_eip" {
  instance = aws_instance.jenkins.id
  domain     = "vpc"
}