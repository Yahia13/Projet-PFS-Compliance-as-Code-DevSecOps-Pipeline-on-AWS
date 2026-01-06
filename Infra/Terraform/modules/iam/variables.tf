variable "project_name" {
  type = string
}
variable "audit_bucket_arn" {
  description = "L'ARN du bucket S3 pour les rapports (passé depuis la racine)"
  type        = string
}

variable "ansible_files_bucket_arn" {
  description = "ARN of the S3 bucket that contains Ansible files"
  type        = string
}

variable "ansible_ssh_key_param_arn" { type = string }

variable "ecr_repo_arn" { type = string }
variable "tfstate_bucket_arn" { type = string }
