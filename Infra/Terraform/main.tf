module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "jenkins_ec2" {
  source       = "./modules/jenkins-ec2"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnets[0]
}
