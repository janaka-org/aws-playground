data "aws_region" "current" {}

data "aws_vpc" "this" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_route_table" "default" {
  route_table_id = data.aws_vpc.this.main_route_table_id
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.this.id

  # field name ref https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  filter {
    name   = "default-for-az"
    values = ["true"]
 }
}

