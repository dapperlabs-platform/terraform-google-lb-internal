output "ip_address" {
  description = "The internal IP addresses assigned to the regional forwarding rules (map by region)."
  value       = { for k, v in google_compute_global_forwarding_rule.default : k => v.ip_address }
}

output "forwarding_rule" {
  description = "The regional forwarding rule self_links (map by region)."
  value       = { for k, v in google_compute_global_forwarding_rule.default : k => v.self_link }
}

output "forwarding_rule_id" {
  description = "The regional forwarding rule ids (map by region)."
  value       = { for k, v in google_compute_global_forwarding_rule.default : k => v.id }
}

output "backend_service" {
  description = "The regional backend service self_links (map by region)."
  value       = { for k, v in google_compute_backend_service.default : k => v.self_link }
}

output "url_map" {
  description = "The URL map self_link."
  value       = google_compute_url_map.default.self_link
}

output "target_proxy" {
  description = "The regional target HTTP proxy self_links (map by region)."
  value       = { for k, v in google_compute_target_http_proxy.default : k => v.self_link }
}

output "subnetwork" {
  description = "The subnetwork self_links (map by region)."
  value       = { for k, v in data.google_compute_subnetwork.subnetwork : k => v.self_link }
}

output "subnetwork_gateway_address" {
  description = "The subnetwork gateway addresses (map by region)."
  value       = { for k, v in data.google_compute_subnetwork.subnetwork : k => v.gateway_address }
}

output "subnetwork_ip_cidr_range" {
  description = "The IP CIDR ranges of the subnetworks (map by region)."
  value       = { for k, v in data.google_compute_subnetwork.subnetwork : k => v.ip_cidr_range }
}

output "subnetwork_secondary_ip_ranges" {
  description = "Secondary IP ranges of the subnetworks (map by region)."
  value       = { for k, v in data.google_compute_subnetwork.subnetwork : k => v.secondary_ip_range }
}
