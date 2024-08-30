provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}


data "kubernetes_service_v1" "service_details" {
  metadata {
    name      = "flask-app-service"
    namespace = "default"
  }
}

locals {
  service_details = {
    name       = data.kubernetes_service_v1.service_details.metadata[0].name
    namespace  = data.kubernetes_service_v1.service_details.metadata[0].namespace
    cluster_ip = data.kubernetes_service_v1.service_details.spec[0].cluster_ip
    port = [
      for p in data.kubernetes_service_v1.service_details.spec[0].port : {
        port        = p.port
        target_port = p.target_port
      }
    ]
  }
}

resource "local_file" "service_details_json" {
  filename = "${path.module}.service_details.json"
  content  = jsonencode(local.service_details)
}
