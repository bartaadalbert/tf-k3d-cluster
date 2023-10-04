variable "K3D_CLUSTER_NAME" {
  description = "The name of the K3D cluster will be used like you explain it."
  type        = string
  default     = "my-k3d-cluster"
}

variable "NUM_MASTERS" {
  description = "Number of master nodes."
  type        = number
  default     = 1
}

variable "NUM_WORKERS" {
  description = "Number of worker nodes."
  type        = number
  default     = 2
}

variable "NODE_IMAGE"{
  description = "Node image"
  type        = string
  default     = "rancher/k3s:v1.27.6-k3s1"
}

variable "API_HOST_IP"{
  description = "The host ip"
  type        = string
  default     = "127.0.0.1"
}

variable "API_HOST_PORT" {
  description = "Host port"
  type        = number
  default     = 6443
}

variable "WAIT_FOR_READY" {
  description = "Whether to wait for the cluster to be ready before continuing"
  type        = bool
  default     = true
}

