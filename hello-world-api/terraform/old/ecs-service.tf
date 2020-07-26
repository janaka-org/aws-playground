variable "vpc_id" {
  description = "A valid VPC ID"
  default     = "vpc-dcf556b8"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to create the service in"
  default     = "janaka-experiments"
}

locals {
  az_list = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  janaka-exp-public-subnets = ["subnet-289d5270", "subnet-63e36c07", "subnet-99de62ef"]
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "ecs-service-role-id" {
  value = data.aws_iam_role.ecs-service-role.id
}

output "ecs-taskdef-arn" {
  value = aws_ecs_task_definition.task-hello-world-api.arn
}

# The load balancer DNS name
output "lb_dns" {
  value = aws_alb.main.dns_name
}

data "aws_ecs_cluster" "janaka-experiments" {
  cluster_name = var.ecs_cluster_name
}

data "aws_iam_role" "ecs-service-role" {
  name = "AWSServiceRoleForECS"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


data "aws_vpc" "main" {
  id = var.vpc_id #"vpc-dcf556b8"
}

resource "aws_alb" "main" {
  name = "hello-world-api-lb"
  subnets = ["subnet-289d5270", "subnet-63e36c07", "subnet-99de62ef"]
  security_groups = [aws_security_group.nsg_lb.id]
  depends_on = [aws_security_group.nsg_lb]
}

resource "aws_alb_target_group" "main-blue" {
  name                 = "hello-world-api-lb-tg-blue"
  port                 = 80 # port that targets receied traffic on
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 20
  depends_on = [aws_alb.main]

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
  name                 = "hello-world-api-lb-tg-green"
  port                 = 80 # port that targets receied traffic on
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 20
  depends_on = [aws_alb.main]

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


resource "aws_security_group" "nsg_lb" {
  name        = "hello-world-api_PROD-lb"
  description = "Allow connections from external resources while limiting connections from hello-world-api_PROD-lb to internal resources"
  vpc_id      = var.vpc_id

}

resource "aws_security_group" "nsg_task" {
  name        = "hello-world-api_PROD_task"
  description = "Limit connections from internal resources while allowing hello-world-api_PROD_task to connect to all external resources"
  vpc_id      = var.vpc_id
}

# Rules for the LB (Targets the task SG)

resource "aws_security_group_rule" "nsg_lb_egress_rule" {
  description              = "Only allow SG hello-world-api_PROD-lb to connect to hello-world-api_PROD-task on port 80"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_task.id

  security_group_id = aws_security_group.nsg_lb.id
}

resource "aws_security_group_rule" "nsg_lb_ingress_rule" {
  description = "Allows lb to accept connections from all resources to port 80"
  type        = "ingress"
  from_port   = "0"
  to_port     = "80"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_lb.id
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = "Only allow connections from SG hello-world-api_PROD_task_lb on port 80"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_lb.id

  security_group_id = aws_security_group.nsg_task.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}

resource "aws_ecs_task_definition" "task-hello-world-api" {
  family                = "task-hello-world-api"
  container_definitions = file("task-definitions/hello-world-api-service.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
}


resource "aws_ecs_service" "service-hello-world-api" {
  name            = "service-hello-world-api"
  launch_type     = "FARGATE"
  cluster         = data.aws_ecs_cluster.janaka-experiments.id
  task_definition = aws_ecs_task_definition.task-hello-world-api.arn
  desired_count   = 1
  #iam_role        = data.aws_iam_role.ecs-service-role.arn # do not use this parameter
  depends_on      = [ aws_alb.main, aws_alb_target_group.main-blue, aws_lb_listener.front_end]

  deployment_controller {
    //type = "CODE_DEPLOY"
    type = "ECS"
  }

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id]
    subnets = ["subnet-289d5270", "subnet-63e36c07", "subnet-99de62ef"]
    assign_public_ip = true # this seems to be recommended by AWS for public services. https://aws.amazon.com/blogs/compute/task-networking-in-aws-fargate/
    #TODO switch this to internal when we get the other service going. But we'll needs NAT Gateways or VPC endpoints for ECR and S3 for tasks on private subnets
  } 

  load_balancer {
    target_group_arn = aws_alb_target_group.main-blue.id
    container_name   = "hello-world-api"
    container_port   = 80
  }

}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/experiments/hello-world-api"
  retention_in_days = 1
 # tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${aws_ecs_task_definition.task-hello-world-api.family}_rev${aws_ecs_task_definition.task-hello-world-api.revision}"
  log_group_name = aws_cloudwatch_log_group.logs.name
}