# Renders task definition file which is needed by Github ECS deploy action and ECS CodeDeploy.
# We want to render this from the container definitions section we have to use for TF to elimiante duplication.
# Ideally this is run as part of the build pipeline. But running TF there is more complicated.  

data "template_file" "continer_defs" {
  template = file("${path.module}/container-definitions.json.tpl")

  vars = {
    container_name  = var.app_name
    image_url       = "<IMAGE_NAME>" #place holder for the task def render GH action 
    aws_region      = local.aws_region
    aws_account_id  = local.aws_account_id
    appmesh_name    = var.app_mesh_id
    ENVOY_LOG_LEVEL = "debug"
    deploy_env_name = var.deploy_env_name
    service_discovery_namespace = var.service_discovery_namespace_name
  }
}

data "template_file" "task_definition" {
  template = file("${path.module}/task-definition.json.tpl")

  vars = {
    container_defs = data.template_file.continer_defs.rendered
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    family = "task-${var.app_name}"
  }
}

resource "local_file" "render" {
  sensitive_content  = data.template_file.task_definition.rendered
  filename = "${path.root}/taskdef.json"
}
