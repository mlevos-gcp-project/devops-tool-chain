/* Varible for K8s cluster dependence */
output "endpoint" {
  value = module.gke.endpoint
}
