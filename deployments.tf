resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_namespace.i,
    kubernetes_persistent_volume_claim.i
  ]

  metadata {
    name      = var.namespace
    labels    = local.common_labels
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = local.common_labels
    }

    template {
      metadata {
        namespace = var.namespace
        labels    = local.common_labels
      }

      spec {
        init_container {
          name              = "${var.namespace}-init"
          image             = "syncthing/syncthing"
          image_pull_policy = "Always"
          command = [
            "sh",
            "-c",
            "mkdir -p /var/syncthing && chown -R 1000:1000 /var/syncthing && syncthing generate --home /var/syncthing/config --gui-user=${var.username} --gui-password=${var.password}"
          ]

          volume_mount {
            name       = "${var.namespace}-persistent-storage"
            mount_path = "/var/syncthing"
          }
        }
        container {
          name              = var.namespace
          image             = "syncthing/syncthing"
          image_pull_policy = "Always"

          resources {
            limits {
              cpu    = "0.8"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          port {
            name           = "web"
            container_port = 8384
          }

          port {
            name           = "sync"
            container_port = 22000
          }

          volume_mount {
            name       = "${var.namespace}-persistent-storage"
            mount_path = "/var/syncthing"
          }
        }

        volume {
          name = "${var.namespace}-persistent-storage"
          persistent_volume_claim {
            claim_name = local.pvc_name
          }
        }
      }
    }
  }
}