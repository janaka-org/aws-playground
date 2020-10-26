output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "fargate_profile_arn" {
    value = aws_eks_fargate_profile.this.arn
}

output "fargate_profile_id" {
    value = aws_eks_fargate_profile.this.id
}