resource "aws_eip" "nat-gw" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat-gw.id
  subnet_id     = tolist(data.aws_subnet_ids.default.ids)[0] # public subnet to place NAT gateway in. 

  depends_on = [aws_eip.nat-gw]
}

# private subnets have a route table with no route to an internet gateway
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html


# Make the default (main) route table private. No internet gateway.
# The _main_ route table gets added to all subnets

resource "aws_default_route_table" "this" {
  default_route_table_id = data.aws_vpc.this.main_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Tier = "private"
    Name = "main-route-table"
  }
}

# route table for the publuc subnets

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.internet_gateway_id 
  }

  tags = {
    Tier = "public"
    Name = "public-custom-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_subnet_ids.default.ids)
  subnet_id      = tolist(data.aws_subnet_ids.default.ids)[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_default_subnet" "default_az1" {
  count = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  # make sure these tags are on all default subnets
  tags = {
    Tier = "public",
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1" # so EKS knows to use for public ELBs
  }
}

