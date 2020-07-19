provider "kubernetes" {  # Load Kubernetes auth data
  load_config_file       = false
  host                   = var.gke_endpoint
  token                  = var.google_client_access_token
  cluster_ca_certificate = base64decode(var.gke_ca_certifacte)
}

resource "null_resource" "dependency_getter" { # Echo for dependencies
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "kubernetes_namespace" "devops_namespace" {
  metadata {
    labels = {
      mylabel = var.devops_namespace
    }
    name = var.devops_namespace
  }
  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "kubernetes_storage_class" "gce_ssd_storage_class" {
  metadata {
    name = "faster"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
  depends_on = [
    kubernetes_namespace.devops_namespace
  ]
}

resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name = "jenkins-pvc"
    namespace= kubernetes_namespace.devops_namespace.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    storage_class_name= kubernetes_storage_class.gce_ssd_storage_class.metadata.0.name
  }
}

resource "null_resource" "jenkins" {
  provisioner "local-exec" {
    command = "envsubst < ${var.resource_folder}/jenkins/values.yaml | helm install jenkins --namespace=${kubernetes_namespace.devops_namespace.metadata.0.name} -f - stable/jenkins"
    environment = {
      HOST  = "jenkins.${var.cluster_domain}",
      ISSUER = var.issuer_name,
      PVC = kubernetes_persistent_volume_claim.jenkins_pvc.metadata.0.name
      GITHUB_USER_NAME = var.github_admin_user
      GITHUB_CLIENT_ID  = var.github_client_id
      GITHUB_SECRET_ID = var.github_secret_id
    }
  }
  depends_on = [
    kubernetes_persistent_volume_claim.jenkins_pvc
  ]
}
