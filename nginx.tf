# Deploy nginx app
resource "kubernetes_deployment" "nginx-web" {
  metadata {
    name = "nginx-web"
    labels = {
      App = "nginx-web"
    }
   }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "nginx-web"
      }
    }
    template {
      metadata {
        labels = {
          App = "nginx-web"
        }
      }
      spec {
        container {
          image = "nginx:1.23.3"
          name  = "nginx-web"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}


# expose nginx service as external load balancer
resource "kubernetes_service_v1" "nginx-web-svc" {
  metadata {
    name = "nginx-web-svc"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx-web.spec.0.template.0.metadata[0].labels.App
    }
    port {
 #    node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

/*
resource "kubernetes_service" "nginx-web-svc" {
  metadata {
    name = "nginx-web-svc"
    namespace = "applications-ns"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx-web.spec.0.template.0.metadata[0].labels.App
    }
    port {
 #    node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
*/
