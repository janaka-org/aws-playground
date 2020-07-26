# The load balancer DNS name
output "lb_dns" {
  value = aws_alb.main.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.nsg_lb.id
}

output "subnet_ids" {
  value = data.aws_subnet_ids.selected.ids
}