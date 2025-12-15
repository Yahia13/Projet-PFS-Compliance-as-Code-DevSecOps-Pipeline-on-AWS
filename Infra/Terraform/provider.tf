provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "pfs-compliance-as-code"
      ManagedBy = "Terraform"
    }
  }
}

