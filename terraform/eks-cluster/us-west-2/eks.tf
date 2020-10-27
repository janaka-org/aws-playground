# these private subnet should be automatically associated with the main route table
# the main route table has been changed to private with a route to the NAT Gateway 
# in network.tf
resource "aws_subnet" "eks_private" {
  vpc_id            = data.aws_vpc.this.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = "172.31.${64 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb"               = "1" # so EKS know to use for internal ALBs
    Name                                            = "eks-private-${data.aws_availability_zones.available.names[count.index]}-172-31-${64 + count.index}",
    Tier                                            = "private"
  }
}




resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = "1.18"
  vpc_config {
    subnet_ids = data.aws_subnet_ids.all.ids
  }

  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler"] #valid values: api, audit, authenticator, controllerManager, scheduler

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_subnet.eks_private,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "janaka-experiments-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_profile.arn
  subnet_ids             = aws_subnet.eks_private[*].id

  selector {
    namespace = "janaka-experiments-namespace"
  }

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system" # needed foe control plane
    labels = {
      "k8s-app" : "kube-dns"
    }
  }


  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role.eks_fargate_profile
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 1
}

