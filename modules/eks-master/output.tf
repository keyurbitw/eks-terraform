output "eks-cluster-endpoint-url" {
  description = "Url of the EKS cluster"
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "eks-cluster-ca" {
  description = "CA Authority"
  value       = aws_eks_cluster.eks-cluster.certificate_authority.0.data
}

output "cluster-token" {
  description = "Cluster Token"
  value       = data.external.aws_iam_authenticator.result.token
}
