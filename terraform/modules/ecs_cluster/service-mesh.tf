resource "aws_appmesh_mesh" "this" {
  name = var.mesh_name

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}
