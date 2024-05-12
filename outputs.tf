# outputs.tf

output "kubeconfig" {
  value = aws_eks_cluster.cluster.kubeconfig_filename
}

output "config_map_aws_auth" {
  value = aws_eks_cluster.cluster.config_map_yaml
}
