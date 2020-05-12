provider "google" {
    credentials = file("${var.google_api_key}")
    project     =  var.project_name
    region      =  var.region
}
resource "null_resource" "activate_service_account" {
  provisioner "local-exec" {
    command = "gcloud auth activate-service-account --project=${var.project_name} --key-file=${var.google_api_key}"
  }
}
 
 
resource "google_compute_network" "vpc_network" {
  name = "${var.k8s_cluster_name}-vpc"
  auto_create_subnetworks = false

  depends_on = [
    null_resource.activate_service_account
  ]
}


module "subnetwork" {
  source = "../subnetwork"
  name          = "${var.k8s_cluster_name}-subnet"
  network       = "${google_compute_network.vpc_network.self_link}"
  ip_cidr_range = var.nodes_ip_cidr_range
  create_secondary_ranges = true
  secondary_ranges        = [
    {
      range_name    = "pods-ip-cidr-range"
      ip_cidr_range = var.pods_ip_cidr_range
    },
    {
      range_name    = "services-ip-cidr-range"
      ip_cidr_range = var.services_ip_cidr_range
    },
  ]
}


module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google"
  project_id                   = var.project_name
  name                            =  var.k8s_cluster_name
  region                          =  var.region
  zones                              = var.zones
  network                      =  google_compute_network.vpc_network.name
  subnetwork                 = module.subnetwork.name
  ip_range_pods              =  module.subnetwork.secondary_range_names[0]
  ip_range_services          = module.subnetwork.secondary_range_names[1]
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  create_service_account = false
}

resource "null_resource" "get_kube_credetial" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials  ${module.gke.name} --region=${module.gke.region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f  ~/.kube/config || true"
  }
}
