output "worker-node-role-name" {
  description = "Name of the master role"
  value       = aws_iam_role.eks-worker-role.name
}

output "worker-node-role-arn" {
  description = "ARN of the master role"
  value       = aws_iam_role.eks-worker-role.arn
}

output "worker-node-instance-profile-name" {
  description = "Name of the instance profile for worker node"
  value       = aws_iam_instance_profile.worker-node-instance-profile.name
}
