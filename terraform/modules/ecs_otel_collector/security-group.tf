resource "aws_security_group" "nsg_task" {
  name        = "${var.app_name}_${var.deploy_env_name}_task_nsg"
  description = "Limit connections from internal resources while allowing ${var.app_name}_${var.deploy_env_name}_task_nsg to connect to all external resources"
  vpc_id      = data.aws_vpc.this.id
}

# control outbound network access for app container.
resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}

# Enable inboud traffic to the task
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description       = "Allow all inbound connections on port 9090"
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["172.31.0.0/16"]

  security_group_id = aws_security_group.nsg_task.id
}