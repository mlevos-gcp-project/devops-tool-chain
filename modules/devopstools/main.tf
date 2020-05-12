resource "null_resource" "depends_on" {
  triggers = {
    depends_on = var.depends
  }
}

resource "null_resource" "devops_namespace" {
  provisioner "local-exec" {
    command = "sleep 60; envsubst < ${var.resource_folder}/${var.devops_namespace_file} | kubectl create -f -"
    environment = {
      NAMESPACE = var.devops_namespace
    }
  }
  depends_on = [
    null_resource.depends_on
  ]
}