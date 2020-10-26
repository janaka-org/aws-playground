terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Janaka"

    workspaces {
      name = "aws-playground-eks-cluster-usw2"
    }
  }
}

provider "aws" {
  version = "~> 2.70"
  profile = "janakapersonal"
  region  = "us-west-2"
}

module "vpc_endpoints" {
  source = "../../modules/vpc_endpoints"

  vpc_name = "janaka-default-vpc"
}
