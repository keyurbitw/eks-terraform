/* Security Group for Worker Nodes */
resource "aws_security_group" "eks-worker-node" {
  name        = "${var.eks-cluster-name}-worker-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.eks-vpc-id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.eks-cluster-name}-worker-node-sg",
    Cluster = var.eks-cluster-name
    Team    = var.team
    Owner   = var.team
    Plan    = "dedicated"
  }
}

/* Add Rule to Worker Node SG for internal commnunication among nodes */
resource "aws_security_group_rule" "worker-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-worker-node.id
  source_security_group_id = aws_security_group.eks-worker-node.id
  to_port                  = 65535
  type                     = "ingress"
}

/* SSH to Worker Nodes */
resource "aws_security_group_rule" "workstation-to-eks-worker-node-ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the Kubernetes nodes directly."
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-worker-node.id
  to_port           = 22
  type              = "ingress"
}

/* Init Script for the Worker Nodes to connect to master */
locals {
  eks-worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks-cluster-endpoint-url}' --b64-cluster-ca '${var.eks-cluster-ca}' '${var.eks-cluster-name}'
USERDATA
}

/* Benerating SSH Key for Worker Node */
resource "tls_private_key" "eks-worker-node-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks-worker-node-generated-key" {
  key_name   = var.eks-cluster-name
  public_key = tls_private_key.eks-worker-node-key.public_key_openssh
}

/* Launch Configuration for worker nodes */
resource "aws_launch_configuration" "worker-node-launch-config" {
  associate_public_ip_address = true
  iam_instance_profile        = var.worker-node-instance-profile-name
  image_id                    = var.worker-node-ami-id
  instance_type               = "t2.xlarge"
  name_prefix                 = "terraform-eks"
  security_groups             = [aws_security_group.eks-worker-node.id]
  user_data_base64            = base64encode(local.eks-worker-node-userdata)
  key_name                    = aws_key_pair.eks-worker-node-generated-key.key_name
  lifecycle {
    create_before_destroy = true
  }
}

/* ASG for worker nodes for HA */
resource "aws_autoscaling_group" "public-worker-node-asg" {
  desired_capacity     = "3"
  launch_configuration = aws_launch_configuration.worker-node-launch-config.id
  max_size             = "3"
  min_size             = "1"
  name                 = "${var.eks-cluster-name}-public-worker-node"
  vpc_zone_identifier  = [var.public-subnet-id]

  tag {
    key                 = "Name"
    value               = "terraform-tf-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/example"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "private-worker-node-asg" {
  desired_capacity     = "3"
  launch_configuration = aws_launch_configuration.worker-node-launch-config.id
  max_size             = "3"
  min_size             = "1"
  name                 = "${var.eks-cluster-name}-private-worker-node"
  vpc_zone_identifier  = [var.private-subnet-id]

  tag {
    key                 = "Name"
    value               = "terraform-tf-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/example"
    value               = "owned"
    propagate_at_launch = true
  }
}
