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
  metadata {
    name      = "${var.namespace}-pv-claim"
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
  metadata {
    name      = "${var.namespace}-web"
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


resource "kubernetes_ingress" "i" {
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels    = local.common_labels
    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [local.domain_name]
    }
    rule {
      host = local.domain_name
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.i_web.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
