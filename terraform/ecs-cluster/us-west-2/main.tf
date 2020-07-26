terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Janaka"

    workspaces {
      name = "aws-app-mesh-example-vpc-usw2"
    }
  }
}

provider "aws" {
  version = "~> 2.56"
  profile = "janakapersonal"
  region  = "us-west-2"
}

# provider "github" {
#   version = "~> 2.7"
#   #token        = "${var.github_token}"
#   organization = var.github_organization
# }

module "ecs_cluster" {
  source = "../modules/ecs_cluster"

  vpc_name                 = "janaka-default-vpc"
  ecs_cluster_name         = "janaka-experiments"
  github_organisation      = "janaka-org"
  service_discovery_domain = "us-west-2.janaka.local"
  mesh_name                = "janaka-mesh"
  region                   = "us-west-2" # TODO infer region in the module
}

module "ecs_otel_collector" {
  source = "../../modules/ecs_otel_collector"

  app_name                         = "otel-collector"
  vpc_name                         = "janaka-default-vpc"
  deploy_env_name                  = "experiments"
  ecs_cluster_name                 = "janaka-experiments"
  app_mesh_id                      = "janaka-mesh"
  service_discovery_namespace_name = "us-west-2.janaka.local"
  service_discovery_namespace_id   = module.ecs_cluster.service_discovery_namespace_id
  desired_container_count          = 1
  ecs_service_depends_on           = [module.ecs_cluster.depend_on_this_module_ids]

  depends_on = [module.ecs_cluster]
}
