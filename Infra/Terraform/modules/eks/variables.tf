variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}
variable "eks_security_group_ids" {
  type = list(string)
}
variable "jenkins_role_arn" {
  type = string
}
