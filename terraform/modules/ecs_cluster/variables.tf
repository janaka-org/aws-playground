variable "vpc_name" {
  type = string
  description = "Name of the VPC to create resources in."
}

variable "ecs_cluster_name" {
  type = string
  description = "Name to give the ECS cluster being created"
}

variable "region" {
  type = string
  description = "The region to create resources in. TODO infer and remove this argument"
}

variable "github_organisation" {
  type = string
  description = "Name for your github organisation hosting the code repo. Use for CI/CD setup."
}

variable "service_discovery_domain" {
  type = string
  description = "The domain name such as acme.local for the service discovery DNS zone"
}

variable mesh_name {
    type        = string
    description = "The name to use for the service mesh being created."
}

# variable internet_gateway_id {
#     type        = string
#     description = "Internet gateway id"
# }
