variable "aws_region" { default = "eu-central-1" }

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "pfs-compliance-as-code"
}
