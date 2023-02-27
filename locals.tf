locals {
  app_name = "syncthing"
  pvc_name = kubernetes_persistent_volume_claim.i.metadata.0.name
  common_labels = {
    app = local.app_name
  }
  domain_name = "${var.namespace}.boop.ninja"
}