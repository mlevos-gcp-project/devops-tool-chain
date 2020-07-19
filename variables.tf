variable google_api_key {
  type        = string
  description = "api key to provide resources"
}
variable project_name {
  type        = string
  description = "GCP project name"
}

variable region {
  type        = string
  description = "GCP region"
}

variable zones {
  type        = list
  description = "GCP zone"
}

variable gke_name {
  type        = string
  description = "GKE name"
}

variable resource_folder {
  type        = string
  description = "resource_folder"
  default     = "/resources"
}

variable devops_namespace {
  type        = string
  description = "DevOps K8s namespace"
  default     = "tools"
}

variable issuer_email {
  type        = string
  description = "Let's Encrypt email register"
}

variable issuer_name {
  type        = string
  description = "Let's Encrypt issuer name"
  default     = "letsencrypt-prod"
}

variable github_admin_user {
  type        = string
  description = "The user admin for github"
}

variable github_client_id {
  type        = string
  description = "The github application id"
}

variable github_secret_id {
  type        = string
  description = "The github application secret"
}

variable dns_zone_name {
  type        = string
  description = "The github application secret"
}