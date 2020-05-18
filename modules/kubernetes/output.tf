/* Varible for K8s cluster dependence */
output "depended_on" {
  value = google_dns_record_set.ingress_domain.id
}

output "cluster_domain" {
  # remove the dote at the end
  value = trimsuffix( data.google_dns_managed_zone.env_dns_zone.dns_name,  ".")
}
