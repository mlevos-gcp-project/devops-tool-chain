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
}


module "aliased-subnetwork" {
  source = "../subnetwork"

  name          = "aliased-subnet"
  network       = "${google_compute_network.vpc_network.self_link}"
  ip_cidr_range = "10.100.0.0/24"
  create_secondary_ranges = true
  secondary_ranges        = [
    {
      range_name    = "range-1"
      ip_cidr_range = "10.101.0.0/21"
    },
    {
      range_name    = "range-2"
      ip_cidr_range = "10.102.0.0/24"
    },
  ]
}


module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google"
  project_id                   = var.project_name
  name                            =  var.k8s_cluster_name
  region                          =  var.region
  network                      =  google_compute_network.vpc_network.name
  subnetwork                 = module.aliased-subnetwork.name
  ip_range_pods              =  module.aliased-subnetwork.secondary_range_names[0]
  ip_range_services          = module.aliased-subnetwork.secondary_range_names[1]
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  create_service_account = false
}

resource "null_resource" "get_kube_credetial" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials  ${var.k8s_cluster_name} --region=${var.region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f  ~/.kube/config || true"
  }
}
