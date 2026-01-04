variable "aws_region" { default = "eu-central-1" }

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "pfs-compliance-as-code"
}

variable "ansible_ssh_private_key_pem" {
  type      = string
  sensitive = true
}
