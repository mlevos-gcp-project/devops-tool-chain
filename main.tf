provider "google" {
  credentials = file("${var.google_api_key}")
  project     = var.project_name
  region      = var.region
}

data "google_client_config" "default" {}

module "kubernetes" {
  source           = "./modules/kubernetes"
  google_api_key   = var.google_api_key
  project_name     = var.project_name
  region           = var.region
  k8s_cluster_name = var.k8s_cluster_name
  zones            = var.zones
  resource_folder  = "${path.root}/${var.resource_folder}"
  issuer_email     = var.issuer_email
  issuer_name      = var.issuer_name
  google_client_access_token = data.google_client_config.default.access_token
}

module "devopstools" {
  source           = "./modules/devopstools"
  resource_folder  = "${path.root}/${var.resource_folder}"
  devops_namespace = var.devops_namespace
  issuer_name      = var.issuer_name
  issuer_email     = var.issuer_email
  cluster_domain   = module.kubernetes.cluster_domain
  jenkins_password = var.jenkins_password
  google_client_access_token = data.google_client_config.default.access_token
  gke_endpoint = module.kubernetes.gke_endpoint
  gke_ca_certifacte = module.kubernetes.gke_ca_certifacte
  dependencies = [
    module.kubernetes.depended_on
  ]
}
