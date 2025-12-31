############################
# Security Groups (Root)
# - Jenkins SG (EC2)
# - Ansible Manager SG (EC2)
# - EKS Cluster SG
# - EKS Nodes SG
############################

# -------------------------
# 1) Jenkins Security Group
# -------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow SSH and Jenkins UI from anywhere (lab mode)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH to Jenkins"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

# -------------------------
# 1-bis) Ansible Manager Security Group (NEW)
# -------------------------
resource "aws_security_group" "ansible_sg" {
  name        = "${var.project_name}-ansible-sg"
  description = "Allow SSH to Ansible manager (lab mode) + outbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH to Ansible manager"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ansible-sg"
  }
}

# -------------------------
# 1-ter) Allow Ansible -> Jenkins SSH (NEW)
# -------------------------
resource "aws_security_group_rule" "jenkins_ssh_from_ansible" {
  type                     = "ingress"
  security_group_id        = aws_security_group.jenkins_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ansible_sg.id
  description              = "Allow Ansible manager to SSH into Jenkins"
}

# -------------------------
# 2) EKS Cluster Security Group
# -------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "EKS control plane SG"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Outbound to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }
}

# Allow EKS API access ONLY from nodes (recommended)
resource "aws_security_group_rule" "eks_api_from_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow Kubernetes API from worker nodes"
}

# If Jenkins runs kubectl/helm directly and needs the API endpoint
resource "aws_security_group_rule" "eks_api_from_jenkins" {
  type                     = "ingress"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_sg.id
  description              = "Allow Kubernetes API from Jenkins"
}

# (Optional) If Ansible manager runs kubectl/helm too (NEW)
resource "aws_security_group_rule" "eks_api_from_ansible" {
  type                     = "ingress"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ansible_sg.id
  description              = "Allow Kubernetes API from Ansible manager"
}

# -------------------------
# 3) EKS Nodes Security Group
# -------------------------
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Worker nodes SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Node-to-node all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Control plane to nodes (all)"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  # (Optional) SSH to nodes (lab mode)
  ingress {
    description = "SSH to nodes"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    description = "Outbound to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-sg"
  }
}
# (Optional) Allow Ansible manager to SSH into nodes (NEW)
  resource "aws_security_group_rule" "nodes_ssh_from_ansible" {
    type                     = "ingress"
    security_group_id        = aws_security_group.eks_nodes_sg.id
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.ansible_sg.id
    description              = "Allow Ansible manager to SSH into EKS nodes (if needed)"
  }

