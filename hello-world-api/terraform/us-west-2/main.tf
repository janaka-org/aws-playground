terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Janaka"

    workspaces {
      name = "aws-app-mesh-example-hello-world-api-usw2"
    }
  }
}

provider "aws" {
  version = "~> 2.56"
  profile = "janakapersonal"
  region  = "us-west-2"
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


# provider "cloudflare" {
#   version = "~> 2.0"
#   api_token = data.aws_kms_secrets.this.plaintext["cloudflare_token"]
#   account_id = "c18c426b904a5873b3e4b8a7825b0090"
# }

# resource "cloudflare_record" "cname" {
#   zone_id = var.cloudflare_zone_id
#   name    = "hello-world-api"
#   value   = aws_alb.main.dns_name
#   type    = "CNAME"
#   ttl     = 120
# }

module "ecs_service_alb" {
  source = "../../../terraform/modules/ecs_service_alb"

  app_name                         = "hello-world-api"
  vpc_name                         = "janaka-default-vpc"
  deploy_env_name                  = "experiments"
  ecs_cluster_name                 = "janaka-experiments"
  app_mesh_id                      = "janaka-mesh"
  service_discovery_namespace_name = "us-west-2.janaka.local"
  app_container_image              = "janaka/aws-app-mesh-example/hello-world-api:latest"
  desired_container_count          = 1

}

output "lb_dns" {
  value = module.ecs_service_alb.lb_dns
}

output "subnet_ids" {
  value = module.ecs_service_alb.subnet_ids
}
