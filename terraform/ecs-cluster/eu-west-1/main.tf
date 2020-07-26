terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Janaka"

    workspaces {
      name = "aws-app-mesh-example-vpc-euw1"
    }
  }
}

provider "aws" {
  version = "~> 2.56"
  profile = "janakapersonal"
  region  = "eu-west-1"
}

# provider "github" {
#   version = "~> 2.7"
#   #token        = "${var.github_token}"
#   organization = var.github_organization
# }

module "ecs_cluster" {
  source = "../../modules/ecs_cluster"

  vpc_name                 = "janaka-default-vpc"
  ecs_cluster_name         = "janaka-experiments"
  github_organisation      = "janaka-org"
  service_discovery_domain = "eu-west-1.janaka.local"
  mesh_name                = "janaka-mesh"
  region                   = "eu-west-1" # TODO infer region in the module
}
