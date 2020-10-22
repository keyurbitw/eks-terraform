output "eks-cluster-vpc-id" {
  description = "VPC Id"
  value       = aws_vpc.eks-cluster-vpc.id
}

output "eks-cluster-public-subnet-id" {
  description = "Private Subnet Id"
  value       = aws_subnet.eks-cluster-public-subnet.id
}

output "eks-cluster-private-subnet-id" {
  description = "Public Subnet Id"
  value       = aws_subnet.eks-cluster-private-subnet.id
}
