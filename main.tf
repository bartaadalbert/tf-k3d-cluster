
resource "null_resource" "install_k3d" {
  provisioner "local-exec" {
    command = <<EOT
      # Define color variables
      SUCCESS_COLOR="\e[32m"
      INFO_COLOR="\e[36m"
      ERROR_COLOR="\e[31m"
      RESET_COLOR="\e[0m"

      # Detect the OS and architecture
      OS=$(uname | tr '[:upper:]' '[:lower:]')
      ARCH=$(uname -m)

      echo -e "$INFO_COLOR Operating system detected:$RESET_COLOR $SUCCESS_COLOR $OS$RESET_COLOR"
      echo -e "$INFO_COLOR Architecture detected:$RESET_COLOR $SUCCESS_COLOR $ARCH$RESET_COLOR"

      if [[ "$OS" == "windows"* ]]; then
        echo -e "$ERROR_COLOR This script does not support Windows. Please install Docker and k3d manually.$RESET_COLOR"
        exit 1
      fi

      # Check for Docker installation
      if ! command -v docker &> /dev/null; then
        echo -e "$INFO_COLOR Docker not found. Installing...$RESET_COLOR"
        if [[ "$OS" == "linux" ]]; then
          sudo apt update
          sudo apt install -y docker.io
          sudo usermod -aG docker $USER
          sudo systemctl restart docker
        elif [[ "$OS" == "darwin" ]]; then
          brew install --cask docker
        fi
      else
        echo -e "$SUCCESS_COLOR Docker is installed.$RESET_COLOR"
      fi

      # Check for Kubectl installation
      if ! command -v kubectl &> /dev/null; then
        echo -e "$INFO_COLOR Kubectl not found. Installing...$RESET_COLOR"
        if [[ "$OS" == "linux" ]]; then
          if [[ "$ARCH" == "x86_64" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          elif [[ "$ARCH" == "aarch64" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
          fi
        elif [[ "$OS" == "darwin" ]]; then
          if [[ "$ARCH" == "x86_64" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
          elif [[ "$ARCH" == "aarch64" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
          fi
        fi
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
      else
        echo -e "$SUCCESS_COLOR Kubectl is installed.$RESET_COLOR"
      fi

      # Check for K3D installation
      if ! command -v k3d &> /dev/null; then
        echo -e "$INFO_COLOR K3D not found. Installing...$RESET_COLOR"
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
      else
        echo -e "$SUCCESS_COLOR k3d is installed.$RESET_COLOR"
      fi
    EOT
    interpreter = ["bash", "-c"]
    on_failure  = fail
  }
}

resource "k3d_cluster" "create_cluster" {
    name             = var.K3D_CLUSTER_NAME
    servers_count    = var.NUM_MASTERS
    agents_count     = var.NUM_WORKERS
    image            = var.NODE_IMAGE
    kube_api {
        host_ip      = var.API_HOST_IP
        host_port    = var.API_HOST_PORT
    }
    
    ports {
      host_port      = 8080
      container_port = 80
      node_filters = [
        "loadbalancer",
      ]
    }

    k3d_options {
        no_loadbalancer = false
        no_image_volume = false
    }

    kube_config {
        update_default = true
        switch_context = true
    }

}


resource "null_resource" "cluster_ready_check" {
  count = var.WAIT_FOR_READY ? 1 : 0

  depends_on = [k3d_cluster.create_cluster]

  provisioner "local-exec" {
    command = <<-EOC
      # Define color variables
      SUCCESS_COLOR="\e[32m"
      INFO_COLOR="\e[36m"
      ERROR_COLOR="\e[31m"
      RESET_COLOR="\e[0m"

      until [ $(kubectl get nodes --no-headers --context k3d-${var.K3D_CLUSTER_NAME} | grep -v ' Ready ' | wc -l) -eq 0 ]; do 
        echo -e "$INFO_COLOR Waiting for all nodes to become ready... $RESET_COLOR" 
        sleep 2
      done
      echo -e "$SUCCESS_COLOR All nodes are ready. Cluster is now available. $RESET_COLOR"

      echo -e "$INFO_COLOR List of clusters: $RESET_COLOR" 
      k3d cluster get
    EOC
  }
}

resource "null_resource" "get_kubeconfig" {
  depends_on = [k3d_cluster.create_cluster,null_resource.cluster_ready_check]

  provisioner "local-exec" {
    command = "k3d kubeconfig get ${var.K3D_CLUSTER_NAME} > ${path.module}/k3d-config"
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      # Define color variables
      SUCCESS_COLOR="\e[32m"
      INFO_COLOR="\e[36m"
      RESET_COLOR="\e[0m"

      until [ -f "${path.module}/k3d-config" ]; do
        echo -e "$INFO_COLOR Waiting for k3d-config be ready...$RESET_COLOR"
        sleep 2
      done
      echo -e "$SUCCESS_COLOR k3d-config is ready...$RESET_COLOR"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/k3d-config"
  }
   
  triggers = {
    cluster_name = var.K3D_CLUSTER_NAME
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config delete-context k3d-${self.triggers.cluster_name}"
  }
}