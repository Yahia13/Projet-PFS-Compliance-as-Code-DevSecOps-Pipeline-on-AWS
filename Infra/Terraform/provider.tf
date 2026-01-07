provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "pfs-compliance-as-code"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = "${var.project_name}-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
