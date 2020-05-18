variable resource_folder {
}

variable devops_namespace {
}

variable dependencies {
  type = list
}

variable issuer_name {
  type        = string
  description = "Let's Encrypt issuer name"
}
variable issuer_email {
  type        = string
  description = "Let's Encrypt issuer email"
}


variable cluster_domain {
  type        = string
  description = "The cluster domain"
}

variable create_issuer_yml {
  type        = string
  description = "Path to namespace file creation"
  default     = "/create_issuer.yml"
}

variable jenkins_password {
  type        = string
  description = "Jenkins Password"
}