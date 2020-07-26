data "aws_vpc" "this" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.this.id

  # field name ref https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

module "ecs_service" {
  source = "../../../terraform/modules/ecs_service"

  app_name                         = var.app_name
  vpc_name                         = var.vpc_name
  ecs_cluster_name                 = var.ecs_cluster_name
  app_mesh_id                      = var.app_mesh_id
  service_discovery_namespace_name = var.service_discovery_namespace_name # e.g. "us-west-2.janaka.local"
  deploy_env_name                  = var.deploy_env_name
  app_container_image              = var.app_container_image # e.g. "janaka/aws-app-mesh-example/hello-world-api:latest"
  alb_target_group_id              = aws_alb_target_group.main-blue.id
  desired_container_count          = var.desired_container_count

  ecs_service_depends_on = [aws_alb.main, aws_alb_target_group.main-blue, aws_lb_listener.front_end]

}

# Enable inboud traffic to the app container from the ALB
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = "Enable inbound connections from the ALB ${aws_security_group.nsg_lb.id} to the app container"
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_lb.id                  #module.ecs_service_alb.alb_security_group_id
  security_group_id        = module.ecs_service.ecs_task_security_group_id #aws_security_group.nsg_task.id

  depends_on = [aws_security_group.nsg_lb]
}

# resource "aws_security_group_rule" "nsg_task_ingress_rule" {
#   description              = "Enable inbound traffic from anything on port 80"
#   type                     = "ingress"
#   from_port                = "0"
#   to_port                  = "0"
#   protocol                 = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id        = module.ecs_service.ecs_task_security_group_id #aws_security_group.nsg_task.id

#   depends_on = [aws_security_group.nsg_lb]
# }


# Create ALB
resource "aws_alb" "main" {
  name            = "${var.app_name}-lb"
  internal        = false
  load_balancer_type = "application"
  enable_http2 = true
  ip_address_type = "ipv4"
  subnets         = data.aws_subnet_ids.selected.ids
  security_groups = [aws_security_group.nsg_lb.id]
  depends_on      = [aws_security_group.nsg_lb]
}

resource "aws_alb_target_group" "main-blue" {
  name                 = "${var.app_name}-lb-tg-blue"
  port                 = 80 # port that targets receive traffic on
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.this.id
  target_type          = "ip"
  deregistration_delay = 20
  depends_on           = [aws_alb.main]

  health_check {
    path                = "/healthcheck"
    matcher             = 200
    interval            = 30
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_alb_target_group" "main-green" {
  name                 = "${var.app_name}-lb-tg-green"
  port                 = 80 # port that targets receive traffic on
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.this.id
  target_type          = "ip"
  deregistration_delay = 20
  depends_on           = [aws_alb.main]

  health_check {
    path                = "/healthcheck"
    matcher             = 200
    interval            = 30
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main-blue.id
  }

  depends_on = [aws_alb.main, aws_alb_target_group.main-blue]
}

## ALB attached security group
resource "aws_security_group" "nsg_lb" {
  name        = "${var.app_name}_${var.deploy_env_name}_lb_nsg"
  description = "Allow connections from external resources while limiting connections from ${var.app_name}_${var.deploy_env_name}_lb_nsg to internal resources"
  vpc_id      = data.aws_vpc.this.id
}


resource "aws_security_group_rule" "nsg_lb_egress_rule" {
  description              = "Enable outbound ALB connections to the app container from SG ${module.ecs_service.ecs_task_security_group_id}"
  type                     = "egress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = module.ecs_service.ecs_task_security_group_id
  security_group_id        = aws_security_group.nsg_lb.id
}


# resource "aws_security_group_rule" "nsg_lb_egress_rule" {
#   description              = "Enable outbound connections to anything on port 80"
#   type                     = "egress"
#   from_port                = "0"
#   to_port                  = "0"
#   protocol                 = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id        = aws_security_group.nsg_lb.id
# }

resource "aws_security_group_rule" "nsg_lb_ingress_rule" {
  description = "Allows lb to accept connections from all resources to port 80"
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_lb.id
}


# resource "aws_lb_target_group_attachment" "this" {
#   target_group_arn = aws_alb_target_group.main-blue.arn
#   target_id        = var.app_container_name
#   port             = 80
# }
