variable "eks_cluster_name" {
  type = string
  description = "Name to give the EKS cluster being created"
  default = "janaka-experiments"
}

variable "vpc_name" {
  type = string
  description = "Name of the VPC to create resources in."
  default = "janaka-default-vpc"
}