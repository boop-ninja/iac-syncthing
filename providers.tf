variable "kube_host" {
  default = ""
}
variable "kube_crt" {
  default = ""
}
variable "kube_key" {
  default = ""
}

provider "helm" {
  kubernetes {
    host               = var.kube_host
    client_certificate = base64decode(var.kube_crt)
    client_key         = base64decode(var.kube_key)
    insecure           = true
  }
}

provider "kubernetes" {
  host               = var.kube_host
  client_certificate = base64decode(var.kube_crt)
  client_key         = base64decode(var.kube_key)
  insecure           = true
}