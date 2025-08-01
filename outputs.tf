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
