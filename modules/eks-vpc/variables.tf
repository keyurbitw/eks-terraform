variable "team" {
  default = "cloudops"
}

variable "eks-cluster-name" {
  default = "eks-cluster"
}

variable "aws-region" {
  default = "us-west-2"
}

variable "vpc-cidr-block" {
  default = "10.0.0.0/16"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsHostNames" {
  default = true
}

variable "public-subnet-count" {
  default = 1
}

variable "private-subnet-count" {
  default = 1
}

variable "public-subnet-aws-az" {
  default = "us-west-2a"
}

variable "public-subnet-cidr" {
  default = "10.2.0.64/26"
}

variable "private-subnet-aws-az" {
  default = "us-west-2b"
}

variable "private-subnet-cidr" {
  default = "10.2.0.0/26"
}
