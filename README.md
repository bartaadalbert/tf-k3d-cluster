# Terraform K3D Cluster Module

This Terraform module automates the creation of a K3D (Kubernetes IN Docker) cluster. It simplifies the process of setting up K3D, configuring the cluster, and specifying the number of master and worker nodes. With node labeling for better control and scheduling, this module streamlines K3D cluster creation.

## Prerequisites

Before using this module, ensure you have the following prerequisites installed:

- Terraform 0.13 and later.
- Docker must be installed.

## Usage

To create a K3D cluster with this module, follow these steps:

1. Include the module in your Terraform script, providing necessary variables:

```hcl
module "k3d_cluster" {
  source            = "github.com/bartaadalbert/tf-k3d-cluster"
  K3D_CLUSTER_NAME  = "my-k3d-cluster"
  NUM_MASTERS       = 1
  NUM_WORKERS       = 2
  NODE_IMAGE        = "rancher/k3s:v1.27.6-k3s1"
  API_HOST_IP       = "127.0.0.1"
  API_HOST_PORT     = 6443
  WAIT_FOR_READY    = true

}
```
Replace "my-k3d-cluster", 1, and 2 with your desired K3D cluster name, number of master nodes, and number of worker nodes, respectively.

Additional parameters like NODE_IMAGE,API_HOST_IP,API_HOST_PORT and WAIT_FOR_READY can also be modified to suit your needs.

##  Outputs

This module has the following outputs:

    client_key: The client key for the created cluster. This is used to authenticate with the cluster.
    ca: The Certificate Authority (CA) certificate for the created cluster. This is used to validate the server certificate.
    crt: The client certificate for the created cluster. This is used along with the client key to authenticate with the cluster.
    endpoint: The endpoint (API server URL) for the created cluster. This is used to communicate with the cluster.

## Example
Define your variables:
```
variable "K3D_CLUSTER_NAME" {
  description = "The name of the K3D cluster"
  default     = "my-k3d-cluster"
}

variable "NUM_MASTERS" {
  description = "Number of master nodes"
  default     = 1
}

variable "NUM_WORKERS" {
  description = "Number of worker nodes"
  default     = 2
}
```

## Use the module with the defined variables:
```hcl
module "k3d_cluster" {
  source            = "github.com/bartaadalbert/tf-k3d-cluster?ref=cert"
  K3D_CLUSTER_NAME  = var.K3D_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS
}

```

## Contributing

If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request. Your contributions are welcome!

Modify this draft to align with your project's specific details and requirements, and make sure to update the source URL to match your actual Terraform module's repository location.