

provider "kubernetes" {
  load_config_file       = false
  host                   = module.gke.endpoint
  token                  = var.google_client_access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = module.gke.endpoint
    token                  = var.google_client_access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

resource "null_resource" "activate_service_account" {
  provisioner "local-exec" {
    command = "gcloud auth activate-service-account --project=${var.project_name} --key-file=${var.google_api_key}"
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "${var.k8s_cluster_name}-vpc"
  auto_create_subnetworks = false

  depends_on = [
    null_resource.activate_service_account
  ]
}


module "subnetwork" {
  source                  = "../subnetwork"
  name                    = "${var.k8s_cluster_name}-subnet"
  network                 = "${google_compute_network.vpc_network.self_link}"
  ip_cidr_range           = var.nodes_ip_cidr_range
  create_secondary_ranges = true
  secondary_ranges = [
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
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_name
  name                       = var.k8s_cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = google_compute_network.vpc_network.name
  subnetwork                 = module.subnetwork.name
  ip_range_pods              = module.subnetwork.secondary_range_names[0]
  ip_range_services          = module.subnetwork.secondary_range_names[1]
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  create_service_account     = false

  node_pools = [
    {
      name         = "pool-01"
      autoscaling  = false
      node_count   = 5
      auto_upgrade = true
    }
  ]
  node_pools_metadata = {
    pool-01 = {
      shutdown-script = file("${path.module}/data/shutdown-script.sh")
    }
  }
  node_pools_tags = {
    pool-01 = [
      "pool-01-tags",
    ]
  }
}

/** This resource is creat to use module depences **/
resource "null_resource" "print_created_message" {
  provisioner "local-exec" {
    command = "echo New cluster ${module.gke.name} created with teh endpoitn ${module.gke.endpoint} "
  }
}


resource "null_resource" "get_kube_credential" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials  ${module.gke.name} --region=${module.gke.region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f  ~/.kube/config || true"
  }
  depends_on = [
    null_resource.print_created_message
  ]
}

resource "helm_release" "ingress" {
  name  = "nginx-ingress"
  chart = "stable/nginx-ingress"
  depends_on = [
    null_resource.get_kube_credential
  ]
}

resource "helm_release" "cert_manager" {
  name    = "cert-manager"
  chart   = "jetstack/cert-manager"
  version = "v0.15.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [
    null_resource.get_kube_credential
  ]
}


data "kubernetes_service" "nginx_ingress" {
  metadata {
    name = "nginx-ingress-controller"
  }
  depends_on = [
    helm_release.ingress
  ]
}

data "google_dns_managed_zone" "env_dns_zone" {
  name = "mlevostre"
}

resource "google_dns_record_set" "ingress_domain" {
  name         = "*.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = [data.kubernetes_service.nginx_ingress.load_balancer_ingress.0.ip]
}
