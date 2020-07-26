variable "vpc_name" {
  type        = string
  description = "Name of the VPC, as defined in the `Name` tag, where `ecs_cluster_name` exists"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to create the service in. It should be in the `vpc_name`"
  type        = string
}

variable "app_name" {
  description = "Name of the application being deployed. This will be used as prefix/suffix in naming various ECS objects"
  type        = string
}

variable "app_container_image" {
  description = "The name of the repo and image name in the formate of `repo/image_name:tag`. Must be in ECR in the same region as where the service is being created"
}

variable "deploy_env_name" {
  description = "Name of the environment to which this service is being deployed. e.g. production, stage, test, experiments. Likely a 1:1 with ECS clusters"
  type        = string
}

variable "app_mesh_id" {
  type        = string
  description = "The id of the app mesh instance this service belongs to"
}

variable "service_discovery_namespace_name" {
  type        = string
  description = "the servce discovery name space this service belongs to e.g. acme.local"
}

# variable "subnet_tier" {
#   type = string
#   description = "The subnet to create the service in. Selects subnets with a tag name=`Tier` and the value passed here. Use `private` and `public`."
#   default = "private"

#   validation {
#     # regex(...) fails if it cannot find a match
#     condition     = var.subnet_tier == "private" || var.subnet_tier == "public"
#     error_message = "Valid values are `private` or `public`. Subnets must have a tag key=`Tier` and value=`private|public`."
#   }

# }

variable "ecs_service_depends_on" {
  type        = any
  description = "A list of resource that the aws_ecs_resource in this module should depend on."
  default     = null
}

variable "desired_container_count" {
  type = number
  description = "The number of containers you want to run."
  default = 1
}

# variable "alb_security_group_id" {
#   type = string
#   description = "(optional) ALB security group ID used to lockdown public facing services"
#   default = ""
# }

variable "alb_target_group_id" {
  type        = string
  description = "(optional) ALB target group ID"
  default     = ""
}


# variable "cloudflare_zone_id" {
#   type = string
#   description = "CloudFlare zone id for the DNS zone records will get created in"
# }

# variable "cloudflare_api_token" {
#   type = string
#   description = "API token with write access to the zone for DNS records"
# }

# variable "cloudflare_account_id" {
#   type = string
#   description = ""
# }
