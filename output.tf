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