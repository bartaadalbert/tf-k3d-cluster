data "local_file" "client_key" {
  depends_on = [null_resource.extract_kubeconfig_values]
  filename = "${path.module}/k3d-client-key.pem"
}

data "local_file" "ca" {
  depends_on = [null_resource.extract_kubeconfig_values]
  filename = "${path.module}/k3d-ca.crt"
}

data "local_file" "crt" {
  depends_on = [null_resource.extract_kubeconfig_values]
  filename = "${path.module}/k3d-crt.crt"
}

data "local_file" "endpoint" {
  depends_on = [null_resource.extract_kubeconfig_values]
  filename = "${path.module}/k3d-endpoint"
}


output "client_key" {
  description = "The client key"
  value       = data.local_file.client_key.content
}

output "ca" {
  description = "The cluster CA certificate"
  value       = data.local_file.ca.content
}

output "crt" {
  description = "The client certificate"
  value       = data.local_file.crt.content
}

output "endpoint" {
  description = "The endpoint"
  value       = data.local_file.endpoint.content
}