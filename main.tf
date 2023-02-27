##################################################################
# Namespace
##################################################################

resource "kubernetes_namespace" "i" {
  metadata {
    annotations = {
      name = var.namespace
    }

    labels = local.common_labels

    name = var.namespace
  }
}

##################################################################
# Persisted Volume Claims
##################################################################

resource "kubernetes_persistent_volume_claim" "i" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${local.app_name}-pv-claim"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20G"
      }
    }
  }
}


##################################################################
# Services
##################################################################

resource "kubernetes_service" "i_web" {
  depends_on = [kubernetes_deployment.i]
  metadata {
    name      = "${local.app_name}-web"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    selector = local.common_labels

    port {
      name        = "web"
      port        = 80
      target_port = 8384
    }

    type = "ClusterIP"
  }
}

##################################################################
# Ingress
##################################################################


resource "kubernetes_ingress_v1" "i" {
  depends_on = [kubernetes_service.i_web]
  metadata {
    name      = "${local.app_name}-ingress"
    namespace = var.namespace
    labels    = local.common_labels
    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "traefik"
    tls {
      hosts = [local.domain_name]
    }
    rule {
      host = local.domain_name
      http {
        path {

          backend {
            service {
              name = kubernetes_service.i_web.metadata[0].name
              port {
                number = kubernetes_service.i_web.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
