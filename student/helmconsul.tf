provider "helm" {
  version = "0.10.4"
  kubernetes {
    host     = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
    username = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
    password = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"

    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"

    load_config_file = false
  }
}

provider "kubernetes" {
  host     = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
  username = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  password = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"

  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
  
  load_config_file = false
}

resource "local_file" "consul-helm" {
  filename = "clonesuccess.txt"

  provisioner "local-exec" {
    command = "git clone https://github.com/hashicorp/consul-helm.git"
  }
}

resource "helm_release" "consul" {
  name       = "consul-${random_id.project_name.hex}"
  chart      = "consul-helm"
  repository = "./"

  set = {
    name  = "ui.service.type"
    value = "LoadBalancer"
  }

  depends_on = ["local_file.consul-helm"]
}

resource "helm_release" "postgres" {
  name  = "postgres-${random_id.project_name.hex}"
  chart = "stable/postgresql"

  set = {
    name  = "postgresUsername"
    value = "postgres"
  }

  set = {
    name  = "postgresPassword"
    value = "postgres"
  }

  set = {
    name  = "postgresDatabase"
    value = "rails_development"
  }
}
