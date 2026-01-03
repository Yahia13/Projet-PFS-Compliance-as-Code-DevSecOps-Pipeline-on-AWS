variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" { default = "main_pfs_key" } # Nom de votre Key Pair sur AWS

variable "security_group_ids" {
  type = list(string)
}

variable "ansible_bucket" {
  description = "S3 bucket containing Ansible files"
  type        = string
}

