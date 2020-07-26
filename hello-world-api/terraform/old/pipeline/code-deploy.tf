resource "aws_iam_role" "hello_world_api-codedeploy-role" {
    name = "hello_world_api-codedeploy-role"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Sid": "",
    "Effect": "Allow",
    "Principal": {
        "Service": "codedeploy.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
    }
]
}
EOF
}

# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
#   role       = aws_iam_role.hello_world_api-codedeploy-role.name
# }

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"            
  role       = aws_iam_role.hello_world_api-codedeploy-role.name
}

resource "aws_codedeploy_app" "hello-world-api" {
    compute_platform = "ECS"
    name             = "hello-world-api"
}

resource "aws_codedeploy_deployment_group" "hello_world_api" {
  app_name              = aws_codedeploy_app.hello-world-api.name
  deployment_group_name = "hello_world_api-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn      = aws_iam_role.hello_world_api-codedeploy-role.arn



  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

 blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = aws_ecs_service.service-hello-world-api.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.front_end.arn]
      }

      target_group {
        name = aws_alb_target_group.main-blue.name
      }

      target_group {
        name = aws_alb_target_group.main-green.name
      }
    }
  }
}