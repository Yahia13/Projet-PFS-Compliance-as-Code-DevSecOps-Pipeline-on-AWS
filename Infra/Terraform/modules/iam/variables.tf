variable "project_name" {
  type = string
}

variable "jenkins_role_name" {
  description = "Le nom du rôle IAM attaché à l'instance Jenkins"
  type        = string
}

variable "audit_bucket_arn" {
  description = "L'ARN du bucket S3 pour les rapports (passé depuis la racine)"
  type        = string
}