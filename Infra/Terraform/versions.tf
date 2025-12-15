terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "s3-bucket-pfs-backup-tfstate-projets"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}
