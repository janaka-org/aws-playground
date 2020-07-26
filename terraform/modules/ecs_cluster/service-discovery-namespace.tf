resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.service_discovery_domain
  description = "Service discovery namespace ${var.service_discovery_domain}"
  vpc         = data.aws_vpc.this.id
}