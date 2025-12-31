variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" { default = "ma-cle-aws" } # Nom de votre Key Pair sur AWS

variable "security_group_ids" {
  type = list(string)
}
