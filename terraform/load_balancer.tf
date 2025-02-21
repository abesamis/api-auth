resource "google_compute_global_address" "global_ip" {
  name = "global-ip"

  depends_on = [null_resource.api_auth_force_build]
}

resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name                  = "forwarding-rule"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.global_ip.address
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}


# Backend Service for Cloud Run API
resource "google_compute_backend_service" "api_auth_backend" {
  name                  = "${var.auth_service_name}-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = 30
  port_name             = "http"
  enable_cdn            = false

  backend {
    group = google_compute_region_network_endpoint_group.api_auth_neg.id
  }
}

# Backend Service for Frontend Web App
resource "google_compute_backend_service" "frontend_backend" {
  name                  = "frontend-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = 30
  port_name             = "http"
  enable_cdn            = true

  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }
}

# Network Endpoint Group for Cloud Run API
resource "google_compute_region_network_endpoint_group" "api_auth_neg" {
  name                  = "${var.auth_service_name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.auth_service_name
  }

  depends_on = [null_resource.api_auth_force_build]
}

# Network Endpoint Group for Frontend Web App
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "frontend-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.frontend_service_name
  }

  depends_on = [null_resource.api_auth_force_build]
}

# URL Map with Routing Rules
resource "google_compute_url_map" "url_map" {
  name = "url-map"

  # Route /auth to Cloud Run API
  host_rule {
    hosts        = ["api.osposstore.com"]
    path_matcher = "api-auth"
  }

  path_matcher {
    name            = var.auth_service_name
    default_service = google_compute_backend_service.api_auth_backend.id

    route_rules {
      priority = 100
      match_rules {
        prefix_match = "/auth"
      }
      service = google_compute_backend_service.api_auth_backend.id
    }
  }

  # Default - All other traffic goes to the frontend
  #default_service = google_compute_backend_service.frontend_backend.id
  default_service = google_compute_backend_service.api_auth_backend.id
}

