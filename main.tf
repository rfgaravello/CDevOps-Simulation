terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}

# O Terraform se conecta ao Minikube lendo o arquivo de configuração local do kubectl
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "telemetry_app" {
  metadata {
    name = "telemetry-app-deployment"
    labels = {
      app = "telemetry-api"
    }
  }

  spec {
    replicas = 2 # Alta disponibilidade simulada localmente

    selector {
      match_labels = {
        app = "telemetry-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "telemetry-api"
        }
      }

      spec {
        container {
          image = "telemetry-app:local" # Imagem que buildaremos localmente
          name  = "telemetry-container"
          
          port {
            container_port = 8080
          }

          env {
            name  = "APP_ENV"
            value = "staging-local"
          }

          # Provas de vida (Liveness/Readiness probes) fundamentais para resiliência de sistemas
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "telemetry_service" {
  metadata {
    name = "telemetry-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.telemetry_app.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer" # O minikube tunnel vai expor isso na sua máquina
  }
}