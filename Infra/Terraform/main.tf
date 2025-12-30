module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_nodes_role_arn
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

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  instance_profile_name = module.iam.jenkins_instance_profile_name
}


module "ansible_manager" {
  source       = "./modules/ansible-manager"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnets[0]
  ami_id       = data.aws_ami.ubuntu.id 
}