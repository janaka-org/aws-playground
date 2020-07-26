data "aws_region" "this" {}

data "aws_caller_identity" "current" {}

locals {
  aws_region     = data.aws_region.this.name
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

data "aws_iam_role" "ecs-service-role" {
  name = "AWSServiceRoleForECS"
}

data "aws_vpc" "this" {
  #id = var.vpc_id #"vpc-dcf556b8"
  tags = {
    Name = var.vpc_name
  }
}

# data "aws_route53_zone" "this" {
#   name         = "${var.service_discovery_namespace_name}."
#   private_zone = true
# }

# data "aws_subnet_ids" "selected" {
#   vpc_id = data.aws_vpc.this.id

#   tags = {
#     Tier = var.subnet_tier
#   }
# }

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.this.id

  # field name ref https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  filter {
    name   = "default-for-az"
    values = ["true"]
 }
}


data "template_file" "continer_definitions" {
  #template = file("${path.module}/container-definitions.json.tpl")
  template = file("${path.module}/container-definitions_otel-collector.json.tpl")

  # keep render-taskdef.tf in sync with changes here.
  vars = {
    container_name              = var.app_name
    image_url                   = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/janaka/otel/opentelemetry-collector-contrib:latest" # pulling the apps images from a single region
    aws_region                  = local.aws_region
    aws_account_id              = local.aws_account_id
    appmesh_name                = var.app_mesh_id
    deploy_env_name             = var.deploy_env_name
    service_discovery_namespace = var.service_discovery_namespace_name
  }
}
