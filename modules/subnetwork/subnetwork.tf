/******************************************
  Create subnetwork without secondary_range
 *****************************************/
resource "google_compute_subnetwork" "basic" {
  count = var.create_secondary_ranges ? 0 : 1

  name                     = var.name
  description              = var.description != "" ? var.description : local.description
  region                   = var.region
  ip_cidr_range            = var.ip_cidr_range
  network                  = var.network
  private_ip_google_access = true
}

/******************************************
  Create subnetwork with secondary_range
 *****************************************/
resource "google_compute_subnetwork" "ranged" {
  count = var.create_secondary_ranges ? 1 : 0

  name                     = var.name
  description              = var.description != "" ? var.description : local.description
  region                   = var.region
  ip_cidr_range            = var.ip_cidr_range
  network                  = var.network
  secondary_ip_range       = var.secondary_ranges
  private_ip_google_access = true
}