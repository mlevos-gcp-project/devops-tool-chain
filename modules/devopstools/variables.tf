variable resource_folder {
}

variable devops_namespace {
}

variable depends {
        type = string
        description= "Wait for K8s cluster provisioning"
}

variable devops_namespace_file {
        type = string
        description="Path to namespace file creation"
        default = "/create_namespace.yml"
}