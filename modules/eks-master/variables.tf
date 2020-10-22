variable "team" {
  default = "cloudops"
}

variable "eks-cluster-name" {
  default = "eks-cluster"
}

variable "eks-vpc-id" {
  description = "VPC Id"
}

variable "eks-subnet-ids" {
  type = list
  description = "Subnet Id"
}

variable "eks-master-role-arn" {
  description = "EKS Master Role ARN"
}
