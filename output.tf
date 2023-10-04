data "local_file" "kubeconfig" {
  depends_on = [null_resource.get_kubeconfig]
  filename = "${path.module}/k3d-config"
}

output "kubeconfig" {
  depends_on = [null_resource.get_kubeconfig]
  description = "The kubeconfig for the created cluster."
  value       = "${path.module}/k3d-config"
}

