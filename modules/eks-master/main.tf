/* Security Group for Control Plane */
resource "aws_security_group" "eks-master-sg" {
  name        = "${var.eks-cluster-name}-eks-master-sg"
  description = "${var.eks-cluster-name} Security Group"
  vpc_id      = var.eks-vpc-id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.eks-cluster-name}-eks-master-sg",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Provison EKS Master Control Plane */
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.eks-cluster-name
  role_arn = var.eks-master-role-arn
  vpc_config {
    subnet_ids         = var.eks-subnet-ids
    security_group_ids = [aws_security_group.eks-master-sg.id]
  }
  depends_on = [
    aws_security_group.eks-master-sg,
  ]

  tags = {
    Name  = var.eks-cluster-name,
    Team  = var.team,
    Owner = var.team,
    Plan  = "dedicated",
  }
}

/* Getting cluster token */
data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.eks-cluster-name} | jq -r -c .status"]

  depends_on = [
    aws_eks_cluster.eks-cluster
  ]
}
