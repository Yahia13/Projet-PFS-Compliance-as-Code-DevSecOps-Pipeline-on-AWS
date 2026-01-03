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
  source            = "./modules/iam"
  project_name      = var.project_name
  
  # Tu passes l'ARN du bucket défini dans s3.tf
  audit_bucket_arn  = aws_s3_bucket.audit_reports.arn
  
  # Tu passes le nom du rôle Jenkins (récupéré depuis le module jenkins_ec2 ou défini ici)
  # Si ton module jenkins_ec2 crée le rôle, utilise :
  jenkins_role_name = module.jenkins_ec2.role_name 
}


module "jenkins_ec2" {
  source       = "./modules/jenkins-ec2"
  project_name = var.project_name

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.jenkins_sg.id]

  instance_profile_name = module.iam.jenkins_instance_profile_name
}

module "ansible_manager" {
  source       = "./modules/ansible-manager"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.ansible_sg.id]
  ansible_bucket = aws_s3_bucket.ansible_bucket.id
}
