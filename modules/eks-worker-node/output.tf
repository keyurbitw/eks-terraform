output "worker-node-private-key" {
  value = tls_private_key.eks-worker-node-key.private_key_pem
}

output "worker-node-public-key" {
  value = tls_private_key.eks-worker-node-key.public_key_pem
}
