# 1. Le Groupe de Sécurité (Le Pare-feu de la machine)
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Autoriser SSH et Jenkins"
  vpc_id      = var.vpc_id

  # Port 8080 : Interface Web de Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Port 22 : Pour qu'Ansible puisse se connecter en SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser toute sortie vers Internet (pour télécharger les outils)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-jenkins-sg" }
}

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
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true # Très important pour y accéder

  root_block_device {
    volume_size = 20 # 20 Go suffisent pour commencer
  }

  tags = { Name = "${var.project_name}-jenkins-server" }
}