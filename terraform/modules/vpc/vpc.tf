# use the default. See data.tf


# resource "aws_vpc" "this" {
#   cidr_block           = "172.31.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = var.vpc_name
#   }
# }

# resource "aws_internet_gateway" "this" {
#   vpc_id = aws_vpc.this.id
# }
