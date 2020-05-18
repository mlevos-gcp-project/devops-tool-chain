variable google_api_key {}

variable project_name {}

variable region {}

variable zones {}

variable k8s_cluster_name {}

variable resource_folder {}

variable pods_ip_cidr_range {
  type        = string
  description = "Pods IP range in subnetwork"
  default     = "10.101.0.0/21"
}

variable services_ip_cidr_range {
  type        = string
  description = "Services  IP range in subnetwork"
  default     = "10.102.0.0/24"
}

variable nodes_ip_cidr_range {
  type        = string
  description = "Nodes  IP range in subnetwork"
  default     = "10.100.0.0/24"
}

variable issuer_name {
  type        = string
  description = "Let's Encrypt issuer name"
  default     = "letsencrypt-prod"
}

variable issuer_email {
  type        = string
  description = "Let's Encrypt email register"
}

variable create_issuer_yml {
  type        = string
  description = "Path to namespace file creation"
  default     = "/create_issuer.yml"
}
