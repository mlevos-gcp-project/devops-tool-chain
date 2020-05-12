variable google_api_key {
    type = string
    description="api key to provide resources"
}
variable project_name {
    type = string
    description="GCP project name"
}

variable region {
    type = string
    description="GCP region"
}

variable zones {
    type = list
    description="GCP zone"
}
       
variable k8s_cluster_name {
    type = string
    description="K8S cluster name"
}

variable resource_folder {
    type = string
    description="resource_folder"
    default = "/resources"
}

variable devops_namespace {
    type = string
    description="DevOps K8s namespace"
    default = "devops-namespace"
}
