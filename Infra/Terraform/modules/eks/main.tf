# 1. Le Cluster EKS (Le "Cerveau")
resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-cluster"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = var.eks_security_group_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

   # ✅ REQUIRED for EKS Access Entries
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

# 2. Le Node Group (Les "Muscles" - Les serveurs de travail)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"] # Taille des machines (suffisant pour un test)

  # S'assure que le cluster est créé avant de lancer les nodes
  depends_on = [
    aws_eks_cluster.this
  ]
}


