variable "team" {
  default = "cloudops"
}

variable "eks-cluster-name" {
  default = "eks-cluster"
}

variable "eks-vpc-id" {
  description = "VPC Id"
}

variable "worker-node-ami-id" {
  description = "AMI Id for Worker Nodes"
}

variable "eks-cluster-endpoint-url" {
  description = "Url of the EKS cluster"
}

variable "eks-cluster-ca" {
  description = "CA Authority"
}

variable "worker-node-instance-profile-name" {
  description = "Worker Node Instance Profile Name"
}

variable "public-subnet-id" {
  description = "Subnet to launch instances in public subnet"
}

variable "private-subnet-id" {
  description = "Subnet to launch instances in private subnet"
}
