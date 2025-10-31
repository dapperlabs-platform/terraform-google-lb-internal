variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  type        = string
  default     = ""
}

variable "regions" {
  description = "Map of regions with their configuration. Each region must have zones and proxy_only_ip."
  type = map(object({
    zones         = list(string)
    proxy_only_ip = string
  }))
}

variable "default_region" {
  description = "The region used for the default backend service in the URL map. If not set, uses the first region in the regions map."
  type        = string
  default     = null
}

variable "network" {
  description = "Name of the network to create resources in."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Name of the subnetwork to create resources in."
  type        = string
  default     = "default"
}

variable "network_project" {
  description = "Name of the project for the network. Useful for shared VPC. Default is var.project."
  type        = string
  default     = ""
}

variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources."
  type        = string
  default     = ""
}

variable "backends" {
  description = "List of backends. Each backend should have 'group' (NEG name) and optional fields like 'description', 'balancing_mode', etc. The NEG name is the same across all regions and will be automatically constructed into the full GCP resource URL for each region/zone."
  type = list(object({
    group                 = string
    description           = optional(string, null),
    balancing_mode        = optional(string, "RATE")
    capacity_scaler       = optional(number, 100)
    max_rate_per_endpoint = optional(number, 100)
  }))
}

variable "session_affinity" {
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  type        = string
  default     = "NONE"
}

variable "port_range" {
  description = "Port range to forward to backend services. Max is 5. The `ports` or `all_ports` are mutually exclusive."
  type        = list(string)
  default     = ["80"]
}

variable "port" {
  description = "Port to forward to backend services. Max is 5. The `ports` or `all_ports` are mutually exclusive."
  type        = string
  default     = "80"
}


variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"
  type = object({
    type                = string
    check_interval_sec  = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    timeout_sec         = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    response            = optional(string, null)
    proxy_header        = optional(string, null)
    port                = optional(number, 80)
    port_name           = optional(string, null)
    request             = optional(string, null)
    request_path        = optional(string, null)
    host                = optional(string, null)
    enable_log          = optional(bool, false)
  })
}

variable "source_tags" {
  description = "List of source tags for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "target_tags" {
  description = "List of target tags for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "source_ip_ranges" {
  description = "List of source ip ranges for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "source_service_accounts" {
  description = "List of source service accounts for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "target_service_accounts" {
  description = "List of target service accounts for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}


variable "ip_protocol" {
  description = "The IP protocol for the backend and frontend forwarding rule. TCP or UDP."
  type        = string
  default     = "TCP"
}

variable "connection_draining_timeout_sec" {
  description = "Time for which instance will be drained"
  default     = null
  type        = number
}

variable "create_backend_firewall" {
  description = "Controls if firewall rules for the backends will be created or not. Health-check firewall rules are controlled separately."
  default     = true
  type        = bool
}

variable "create_health_check_firewall" {
  description = "Controls if firewall rules for the health check will be created or not. If this rule is not present backend healthcheck will fail."
  default     = true
  type        = bool
}

variable "firewall_enable_logging" {
  description = "Controls if firewall rules that are created are to have logging configured. This will be ignored for firewall rules that are not created."
  default     = false
  type        = bool
}

variable "labels" {
  description = "The labels to attach to resources created by this module."
  default     = {}
  type        = map(string)
}

variable "dns_record_name" {
  description = "DNS record name"
  type        = string
}

variable "dns_name" {
  description = "Name of the DNS managed zone"
  type        = string
}

variable "dns_managed_zone_name" {
  description = "Name of the DNS managed zone"
  type        = string
}

variable "dns_project" {
  description = "Project ID for DNS resources"
  type        = string
  default     = ""
}

variable "dns_ttl" {
  description = "TTL for DNS record"
  type        = number
  default     = 300
}

variable "geo_locations" {
  description = "List of geo locations for DNS routing policy"
  type = list(object({
    location = string
    health_checked_targets = optional(object({
      internal_load_balancers = list(object({
        ip_address         = string
        ip_protocol        = string
        load_balancer_type = string
        network_url        = string
        port               = string
        project            = string
      }))
    }))
  }))
  default = []
}

# Subnetwork specific variables for advanced configuration
variable "subnetwork_gateway_address" {
  description = "Gateway address of the subnetwork"
  type        = string
  default     = null
}

variable "subnetwork_ip_cidr_range" {
  description = "IP CIDR range of the subnetwork"
  type        = string
  default     = null
}

variable "subnetwork_id" {
  description = "ID of the subnetwork"
  type        = string
  default     = null
}

variable "subnetwork_secondary_ip_ranges" {
  description = "Secondary IP ranges of the subnetwork (for pods, services, etc.)"
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

variable "product_name" {
  description = "Product name for the internal load balancer"
  type        = string
}
