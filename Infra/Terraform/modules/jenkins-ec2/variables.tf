variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_profile_name" {
  type        = string
  description = "Le nom du profil IAM créé dans le module IAM"
}

variable "instance_type" {
  type    = string
  default = "t3.medium" # t3.medium est un bon compromis pour Jenkins (2 vCPU, 4 Go RAM)
}
