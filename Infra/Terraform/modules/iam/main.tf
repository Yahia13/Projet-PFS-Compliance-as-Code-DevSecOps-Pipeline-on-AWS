# ==========================================================
# 1. RÔLE POUR LE CLUSTER EKS (Le cerveau de Kubernetes)
# ==========================================================
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ==========================================================
# 2. RÔLE POUR LES NODES EKS (Les serveurs de calcul)
# ==========================================================
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nodes_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# ==========================================================
# 3. RÔLE POUR JENKINS (Build, Scan & Deploy)
# ==========================================================
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Politique combinée : ECR + EKS + S3
resource "aws_iam_policy" "jenkins_full_policy" {
  name        = "${var.project_name}-jenkins-devsecops-policy"
  description = "Permissions pour ECR, EKS et l'archivage S3 des rapports"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRPush"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEKSDescribe"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3AuditUpload"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.audit_bucket_arn,
          "${var.audit_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attachement unique
resource "aws_iam_role_policy_attachment" "jenkins_attach_everything" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_full_policy.arn
}

# Profil d'instance pour l'EC2 Jenkins
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# ==========================================================
# 4) ANSIBLE MANAGER ROLE (read ansible files from S3 + CW logs + describe EC2)
# ==========================================================
resource "aws_iam_role" "ansible_manager_role" {
  name = "${var.project_name}-ansible-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ansible_manager_policy" {
  name        = "${var.project_name}-ansible-manager-policy"
  description = "Ansible EC2: read Ansible files from S3 + CloudWatch logs + discover Jenkins EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ---- S3 read Ansible bucket ----
      {
        Sid    = "AllowListAnsibleBucket"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [var.ansible_files_bucket_arn]
      },
      {
        Sid    = "AllowGetAnsibleObjects"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = ["${var.ansible_files_bucket_arn}/*"]
      },

      # ---- CloudWatch logs ----
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      # ---- Discover Jenkins EC2 by tags (optional but useful) ----
      {
        Sid    = "AllowDescribeEC2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      # ---- Read SSH Key from SSM Parameter Store ----
      {
        Sid    = "AllowReadSSHKeyFromSSM"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = var.ansible_ssh_key_param_arn
      },
      {
        Sid    = "AllowDecryptSSMParameter"
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        Resource = "*"
      } 

    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_manager_attach" {
  role       = aws_iam_role.ansible_manager_role.name
  policy_arn = aws_iam_policy.ansible_manager_policy.arn
}

resource "aws_iam_instance_profile" "ansible_manager_profile" {
  name = "${var.project_name}-ansible-manager-profile"
  role = aws_iam_role.ansible_manager_role.name
}