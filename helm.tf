# helm.tf

resource "helm_release" "quivr" {
  name       = "quivr"
  repository = "https://charts.example.com/"
  chart      = "quivr"
  version    = "0.1.0"

  values = [
    file("values.yaml")
  ]
}