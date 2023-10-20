/* 

Deploy juice shop on k8s cluster manually

kubectl run my-juiceshop --image bkimminich/juice-shop:latest --port=3000
kubectl expose pod my-juiceshop --type=LoadBalancer --port=80 --target-port=3000 --name=my-juiceshop-service
kubectl get svc

*/

# Deploy the juice shop app and expose service by Terraform

resource "kubernetes_deployment" "juice-shop" {
  metadata {
    name = "juice-shop"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "juice-shop"
      }
    }
    template {
      metadata {
        labels = {
          App = "juice-shop"
        }
      }
      spec {
        container {
          image = "bkimminich/juice-shop"
          name  = "juice-shop"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
#  depends_on = [azurerm_kubernetes_cluster.default]
#  depends_on = [time_sleep.wait_60_seconds]
}


resource "kubernetes_service_v1" "juice-shop-svc" {
  metadata {
    name = "juice-shop-svc"
  }
  spec {
    selector = {
      App = kubernetes_deployment.juice-shop.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

/* 
resource "kubernetes_service" "juice-shop-svc" {
  metadata {
    name = "juice-shop-svc"
    namespace = "applications-ns"
  }
  spec {
    selector = {
      App = kubernetes_deployment.juice-shop.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}
*/