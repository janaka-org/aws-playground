
output "ecs_taskdef_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "ecs_cluster_arn" {
  value = data.aws_ecs_cluster.this.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

# output "endpoint_address" {
#   value = "https://${cloudflare_record.cname.hostname}/api/hello"
# }

output "service_discovery_namespace_id" {
  value = regex("[^\\/]+$", data.aws_route53_zone.this.comment)
}

output "ecs_task_security_group_id" {
  value = aws_security_group.nsg_task.id
}

output "app_container_name" {
  value = var.app_name
}
