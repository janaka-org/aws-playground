variable "vpc_name" {
  type        = string
  description = "Name of the VPC, as defined in the `Name` tag, where `ecs_cluster_name` exists"
}

variable "app_name" {
  description = "Name of the application being deployed. This will be used as prefix/suffix in naming various ECS objects"
  type        = string
}

variable "deploy_env_name" {
  description = "Name of the environment to which this service is being deployed. e.g. production, stage, test, experiments. Likely a 1:1 with ECS clusters"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to create the service in. It should be in the `vpc_name`"
  type        = string
}

variable "app_container_image" {
  description = "The name of the repo and image name in the formate of `repo/image_name:tag` e..g. `janaka/aws-app-mesh-example/hello-world-api:latest`. Must be in ECR in the same region as where the service is being created"
}

variable "app_mesh_id" {
  type        = string
  description = "The id of the app mesh instance this service belongs to"
}

variable "service_discovery_namespace_name" {
  type        = string
  description = "the servce discovery name space this service belongs to e.g. acme.local"
}

variable "desired_container_count" {
  type = number
  description = "The number of containers you want to run."
  default = 1
}

# variable "ecs_task_security_group_id" {
#   type = string
#   description = "task security group ID used to lockdown public facing services"
# }

# variable "app_container_name" {
#   type  = string
#   description = "the name of the app container. Used to attached the target group"
# }






