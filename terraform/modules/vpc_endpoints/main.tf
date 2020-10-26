# TODO: switch to using `/modules/vpc-endpoints` and delete this file.

resource "aws_security_group" "vpce" {
  name   = "vpc-endpoint-sg"
  description = "Enable traffic to ECR and CloudWatch VPC Endpoint"
  vpc_id = data.aws_vpc.this.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }
}

# we create these 3 private endpoints so we don't see to greate a gateway for private sources to get to them.
# Container tasks shouldn't need to have public subnet enabled. We could use a NAT gateway also

resource "aws_vpc_endpoint" "ecr" {
  vpc_id       = data.aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = data.aws_subnet_ids.default.ids #local.janaka-default-private-subnets
  security_group_ids = [aws_security_group.vpce.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [data.aws_vpc.this.main_route_table_id]
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = data.aws_vpc.this.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = data.aws_subnet_ids.default.ids #local.janaka-default-private-subnets
}