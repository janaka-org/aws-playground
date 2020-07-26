terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Janaka"

    workspaces {
      name = "aws-app-mesh-example-time-now-api-euw1"
    }
  }
}

provider "aws" {
  version = "~> 2.56"
  profile = "janakapersonal"
  region  = "eu-west-1"
}

# provider "github" {
#   version = "2.6.1" #personal accounts only work in v2.4.0
#   individual = false
#   organization = "janaka-org"
#   #token has to be set as an system env var called GITHUB_TOKEN. `launchctl setenv GITHUB_TOKEN < settings > developer setting > personal access token >` 
# }

# data "aws_kms_secrets" "this" {
#   secret {
#     # ... potentially other configuration ...
#     name    = "cloudflare_token"
#     payload = "AQICAHjkDtcaqZ2C+j8oYrgJRefGGPgi5s4QCUDIZMMoXDtrygGa5N7QgIT6EOTrshHtuzIAAAAAhzCBhAYJKoZIhvcNAQcGoHcwdQIBADBwBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDHcMjjZE9Ggtu+xTCgIBEIBDvMJ/mo0hFiQY2CJxh2lnriZooFCOVHRyuz3WXZcPxbE0MwTHgWLx3UfRYUNfG6Kp4mOiWE3xUKXdih3ETJmSvgU7fg=="

#     context = {
#       cloudflare = "token"
#     }
#   }
# }


module "ecs_service" {
  source = "../../../terraform/modules/ecs_service"

  app_name                         = "time-now-api"
  vpc_name                         = "janaka-default-vpc"
  deploy_env_name                  = "experiments"
  ecs_cluster_name                 = "janaka-experiments"
  app_mesh_id                      = "janaka-mesh"
  service_discovery_namespace_name = "eu-west-1.janaka.local"
  app_container_image              = "janaka/aws-app-mesh-example/time-now-api:latest"
  subnet_tier                      = "privte"

}

# Enable inboud traffic to the task
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = "Allow all inbound connections on port 80"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.ecs_service.ecs_task_security_group_id #aws_security_group.nsg_task.id
}
