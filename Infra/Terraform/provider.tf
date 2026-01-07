provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "pfs-compliance-as-code"
      ManagedBy = "Terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", var.aws_region, "--cluster-name", module.eks.cluster_name]
  }
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.iam.eks_nodes_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = module.iam.jenkins_role_arn
        username = "jenkins"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks]
}