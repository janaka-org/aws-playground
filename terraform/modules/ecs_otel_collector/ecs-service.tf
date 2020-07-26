resource "aws_ecs_task_definition" "this" {
  family                   = "task-${var.app_name}"
  container_definitions    = data.template_file.continer_definitions.rendered #file("../container-definitions/${var.app_name}_container-def.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ecs_task_role.arn # need this for envoy, xray, and cloud watch agent (envoy metrics not logs) sidecars
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "this" {
  name            = "service-${var.app_name}"
  launch_type     = "FARGATE"
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_container_count
  #iam_role        = data.aws_iam_role.ecs-service-role.arn # do not use this parameter
  #depends_on = [aws_security_group.nsg_task, aws_alb.main, aws_alb_target_group.main-blue, aws_lb_listener.front_end]
  #depends_on = [aws_security_group.nsg_task]
  depends_on = [aws_security_group.nsg_task, var.ecs_service_depends_on]

  deployment_controller {
    //type = "CODE_DEPLOY"
    type = "ECS"
  }

  network_configuration {
    security_groups  = [aws_security_group.nsg_task.id]
    subnets          = data.aws_subnet_ids.selected.ids #var.subnet_ids
    assign_public_ip = true                            # https://aws.amazon.com/blogs/compute/task-networking-in-aws-fargate/
    #TODO switch this to internal when we get the other service going. But we'll needs NAT Gateways or VPC endpoints for ECR and S3 for tasks on private subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }
}

resource "aws_service_discovery_service" "this" {
  name        = var.app_name
  description = "${var.app_name} OTel Collector. Collects and forwards traces to backends"

  dns_config {
    namespace_id = var.service_discovery_namespace_id #regex("[^\\/]+$", data.aws_route53_zone.this.comment)

    dns_records {
      ttl  = 10 # seconds
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # For ECS health checks
  health_check_custom_config {
    failure_threshold = 1
  }

}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${var.deploy_env_name}/${var.app_name}"
  retention_in_days = 1
  # tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${aws_ecs_task_definition.this.family}_rev${aws_ecs_task_definition.this.revision}"
  log_group_name = aws_cloudwatch_log_group.logs.name
}
