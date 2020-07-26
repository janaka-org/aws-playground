output "vpc_id" {
  value = data.aws_vpc.this.id
}

output mesh_id {
  value = aws_appmesh_mesh.this.id
}

output mesh_arn {
  value = aws_appmesh_mesh.this.arn
}

output service_discovery_namespace_id {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output aws_ecs_cluster_id {
  value = aws_ecs_cluster.this.id
}

output depend_on_this_module_ids {
  value = [aws_appmesh_mesh.this.id, aws_service_discovery_private_dns_namespace.this.id, aws_ecs_cluster.this.id]
}