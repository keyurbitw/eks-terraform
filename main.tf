module "eks-master-role" {
  source           = "./modules/eks-mater-role"
  master-role-name = "${var.eks-cluster-name}-master-role"
}

module "eks-node-role" {
  source                = "./modules/eks-node-role"
  worker-node-role-name = "${var.eks-cluster-name}-worker-node-role"
}

module "eks-vpc" {
  source = "./modules/eks-vpc"

  team                  = var.team
  eks-cluster-name      = var.eks-cluster-name
  aws-region            = var.aws-region
  vpc-cidr-block        = var.vpc-cidr-block
  public-subnet-count   = var.public-subnet-count
  private-subnet-count  = var.private-subnet-count
  public-subnet-aws-az  = var.public-subnet-aws-az
  private-subnet-aws-az = var.private-subnet-aws-az
  public-subnet-cidr    = var.public-subnet-cidr
  private-subnet-cidr   = var.private-subnet-cidr
}

module "eks-master" {
  source              = "./modules/eks-master"
  team                = var.team
  eks-cluster-name    = var.team
  eks-vpc-id          = module.eks-vpc.eks-cluster-vpc-id
  eks-subnet-ids      = [module.eks-vpc.eks-cluster-public-subnet-id, module.eks-vpc.eks-cluster-private-subnet-id]
  eks-master-role-arn = module.eks-master-role.eks-master-role-arn
}

module "eks-worker-node" {
  source                            = "./modules/eks-worker-node"
  worker-node-ami-id                = "ami-005995a182420df74"
  eks-vpc-id                        = module.eks-vpc.eks-cluster-vpc-id
  eks-cluster-endpoint-url          = module.eks-master.eks-cluster-endpoint-url
  eks-cluster-ca                    = module.eks-master.eks-cluster-ca
  worker-node-instance-profile-name = module.eks-node-role.worker-node-instance-profile-name
  public-subnet-id                  = module.eks-vpc.eks-cluster-public-subnet-id
  private-subnet-id                 = module.eks-vpc.eks-cluster-private-subnet-id
}

provider "kubernetes" {
  host                   = module.eks-master.eks-cluster-endpoint-url
  cluster_ca_certificate = base64decode(module.eks-master.eks-cluster-ca)
  token                  = module.eks-master.cluster-token
  load_config_file       = false
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<EOF
- rolearn: ${module.eks-node-role.worker-node-role-arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }
  depends_on = [
    module.eks-master
  ]
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks-master.eks-cluster-endpoint-url}
    certificate-authority-data: ${module.eks-master.eks-cluster-ca}
  name: ${var.eks-cluster-name}
contexts:
- context:
    cluster: ${var.eks-cluster-name}
    user: aws
  name: aws@${var.eks-cluster-name}
current-context: ${var.team}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks-cluster-name}"
KUBECONFIG
}
