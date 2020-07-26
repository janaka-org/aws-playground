# Create an ECS service

Creates an ECS Fargate service based on the input arguments. Binds to port 80. Includes Envoy, CloudWatch Agent, and Xray Daemon as side cars.

The app must have a health check endpoint `/healthcheck`. return 200 status for healthy.

The following images must exist in ECR in the region the service is being created in.

- `janaka/amazon/aws-xray-daemon:latest`
- `janaka/amazon/cloudwatch-agent:latest`

All inbound traffic to the task is blocked by default. i.e. there are no inbound/ingress rules on the task security group.
Add rules from the service config like follows.


```terraform
# Enable inboud traffic to the app container from the ALB
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = "Allow all inbound connections on port 80"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = module.ecs_service.ecs_task_security_group_id #aws_security_group.nsg_task.id
}
```

