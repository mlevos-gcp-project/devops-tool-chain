module "kubernetes" {
    source = "./modules/kubernetes"
    google_api_key = var.google_api_key
    project_name = var.project_name
    region = var.region
    k8s_cluster_name = var.k8s_cluster_name
}