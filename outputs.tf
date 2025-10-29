output "ip_address" {
  description = "The internal IP assigned to the global forwarding rule."
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "forwarding_rule" {
  description = "The forwarding rule self_link."
  value       = google_compute_global_forwarding_rule.default.self_link
}

output "forwarding_rule_id" {
  description = "The forwarding rule id."
  value       = google_compute_global_forwarding_rule.default.id
}

output "backend_service" {
  description = "The backend service self_link."
  value       = google_compute_backend_service.default.self_link
}

output "url_map" {
  description = "The URL map self_link."
  value       = google_compute_url_map.default.self_link
}

output "target_proxy" {
  description = "The target HTTP proxy self_link."
  value       = google_compute_target_http_proxy.default.self_link
}

output "subnetwork" {
  description = "The subnetwork self_link."
  value       = data.google_compute_subnetwork.network.self_link
}

output "subnetwork_gateway_address" {
  description = "The subnetwork gateway address."
  value       = data.google_compute_subnetwork.network.gateway_address
}

output "subnetwork_ip_cidr_range" {
  description = "The IP CIDR range of the subnetwork."
  value       = data.google_compute_subnetwork.network.ip_cidr_range
}

output "subnetwork_secondary_ip_ranges" {
  description = "Secondary IP ranges of the subnetwork."
  value       = data.google_compute_subnetwork.network.secondary_ip_range
}
