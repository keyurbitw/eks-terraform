output "eks-master-role-name" {
   description = "Name of the master role"
   value       = aws_iam_role.eks-master-role.name
}

output "eks-master-role-arn" {
  description = "ARN of the master role"
  value       = aws_iam_role.eks-master-role.arn
}
