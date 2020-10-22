output "cluster-kubeconfig" {
  value = local.kubeconfig
  depends_on = [
    module.eks-master
  ]
}

output "worker-node-private-key" {
  value = module.eks-worker-node.worker-node-private-key
}

output "worker-node-public-key" {
   value = module.eks-worker-node.worker-node-public-key
}
