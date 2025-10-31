# Cross region application Internal Load Balancer

locals {
  default_region = var.default_region != null ? var.default_region : keys(var.regions)[0]
}

data "google_compute_network" "network" {
  name    = var.network
  project = var.network_project == "" ? var.project : var.network_project
}

data "google_compute_subnetwork" "subnetwork" {
  for_each = var.regions
  name     = var.subnetwork
  project  = var.network_project
  region   = each.key
}

# Global URL Map
resource "google_compute_url_map" "default" {
  project         = var.network_project
  name            = "${var.product_name}-internal-lb"
  default_service = google_compute_backend_service.default[local.default_region].self_link
}

# Global Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  project = var.network_project
  name    = "${var.product_name}-internal-lb-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

# Regional Forwarding Rule
resource "google_compute_forwarding_rule" "default" {
  for_each              = var.regions
  project               = var.network_project
  name                  = "${var.product_name}-${each.key}"
  region                = each.key
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = data.google_compute_network.network.self_link
  subnetwork            = data.google_compute_subnetwork.subnetwork[each.key].self_link
  target                = google_compute_target_http_proxy.default.self_link
  ip_address            = each.value.proxy_only_ip
  ip_protocol           = var.ip_protocol
  port_range            = var.port
}

# Regional Backend Service
resource "google_compute_backend_service" "default" {
  for_each              = var.regions
  project               = var.project
  name                  = "${var.product_name}-${each.key}"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = var.ip_protocol
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.health_check.id]
  session_affinity      = "NONE"
  locality_lb_policy    = "ROUND_ROBIN"

  dynamic "backend" {
    for_each = flatten([
      for backend_config in var.backends : [
        for zone in each.value.zones : {
          backend_config = backend_config
          zone           = zone
        }
      ]
    ])
    content {
      group                 = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${each.key}-${backend.value.zone}/networkEndpointGroups/${backend.value.backend_config.group}"
      description           = lookup(backend.value.backend_config, "description", null)
      balancing_mode        = lookup(backend.value.backend_config, "balancing_mode", "RATE")
      capacity_scaler       = lookup(backend.value.backend_config, "capacity_scaler", 1)
      max_rate_per_endpoint = lookup(backend.value.backend_config, "max_rate_per_endpoint", null)
    }
  }

  log_config {
    enable = false
  }

}

resource "google_compute_health_check" "health_check" {
  project = var.project
  name    = "${var.product_name}-hc-http"

  http_health_check {
    port         = var.health_check["port"]
    request_path = var.health_check["request_path"]
    host         = var.health_check["host"]
    response     = var.health_check["response"]
    port_name    = var.health_check["port_name"]
    proxy_header = var.health_check["proxy_header"]
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Firewall Rules
resource "google_compute_firewall" "default-ilb-fw" {
  count   = var.create_backend_firewall ? 1 : 0
  project = var.network_project
  name    = "${var.product_name}-ilb-fw"
  network = data.google_compute_network.network.name

  allow {
    protocol = lower(var.ip_protocol)
    ports    = var.port_range
  }

  source_ranges           = var.source_ip_ranges
  source_tags             = var.source_tags
  source_service_accounts = var.source_service_accounts
  target_tags             = var.target_tags
  target_service_accounts = var.target_service_accounts

  dynamic "log_config" {
    for_each = var.firewall_enable_logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "default-hc" {
  for_each = var.create_health_check_firewall ? var.regions : {}
  project  = var.network_project
  name     = "${var.product_name}-${each.key}-hc"
  network  = data.google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = [var.health_check["port"]]
  }

  source_ranges           = ["130.211.0.0/22", "35.191.0.0/16"] # Google Defaults Health check IPs https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  target_tags             = var.target_tags
  target_service_accounts = var.target_service_accounts

  dynamic "log_config" {
    for_each = var.firewall_enable_logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

# DNS CONFIG

data "google_dns_managed_zone" "default" {
  project = var.network_project
  name    = var.dns_name
}

# DNS Record Set with Geo Routing Policy
resource "google_dns_record_set" "geo" {
  count        = var.dns_record_name != null ? 1 : 0
  name         = "${var.dns_record_name}.${var.dns_name}"
  managed_zone = data.google_dns_managed_zone.default.name
  project      = var.network_project
  type         = "A"
  ttl          = var.dns_ttl

  routing_policy {
    dynamic "geo" {
      for_each = var.geo_locations
      content {
        location = geo.value.location

        dynamic "health_checked_targets" {
          for_each = geo.value.health_checked_targets != null ? [geo.value.health_checked_targets] : []
          content {
            dynamic "internal_load_balancers" {
              for_each = health_checked_targets.value.internal_load_balancers
              content {
                ip_address         = internal_load_balancers.value.ip_address
                ip_protocol        = internal_load_balancers.value.ip_protocol
                load_balancer_type = internal_load_balancers.value.load_balancer_type
                network_url        = internal_load_balancers.value.network_url
                port               = internal_load_balancers.value.port
                project            = internal_load_balancers.value.project
              }
            }
          }
        }
      }
    }
  }
}
