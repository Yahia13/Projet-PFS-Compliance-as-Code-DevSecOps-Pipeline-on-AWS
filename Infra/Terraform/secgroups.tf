############################
# Security Groups (Root)
# - Jenkins SG (EC2)
# - EKS Cluster SG
# - EKS Nodes SG
############################

# -------------------------
# 1) Jenkins Security Group
# -------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow SSH and Jenkins UI from admin network"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from admin network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere or restrict to the ip of your admin machine
  }

  ingress {
    description = "Jenkins UI from admin network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere or restrict to the ip of your admin machine
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
# 2) EKS Cluster Security Group
# -------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "EKS control plane SG"
  vpc_id      = module.vpc.vpc_id

  # Egress open (AWS managed control plane needs outbound)
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

# (Optional) If Jenkins runs kubectl directly and needs to reach the API endpoint:
resource "aws_security_group_rule" "eks_api_from_jenkins" {
  type                     = "ingress"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_sg.id
  description              = "Allow Kubernetes API from Jenkins (kubectl/helm)"
}

# -------------------------
# 3) EKS Nodes Security Group
# -------------------------
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Worker nodes SG"
  vpc_id      = module.vpc.vpc_id

  # Node-to-node communication (pods, CNI, etc.)
  ingress {
    description = "Node-to-node all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow control plane to talk to nodes (kubelet / workloads)
  ingress {
    description              = "Control plane to nodes (all)"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    security_groups          = [aws_security_group.eks_cluster_sg.id]
  }

  # (Optional) SSH to nodes for debugging (you can remove this if not needed)
  ingress {
    description = "SSH to nodes from admin network (optional)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere or restrict to the ip of your admin machine
  }

  egress {
    description = "Outbound to anywhere (via NAT from private subnets)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-sg"
  }
}