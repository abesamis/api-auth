resource "google_compute_global_address" "api_auth_ip" {
  name = "api-auth-ip"
}

resource "google_compute_backend_service" "api_auth_backend" {
  name                  = "api-auth-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = 30
  port_name             = "http"
  enable_cdn            = false

  backend {
    group = google_compute_region_network_endpoint_group.api_auth_neg.id
  }
}

resource "google_compute_region_network_endpoint_group" "api_auth_neg" {
  name                  = "api-auth-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.service_name
  }
}

resource "google_cloud_run_service_iam_member" "allow_lb_invocation" {
  location = var.region
  service  = var.service_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-${local.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_cloud_run_domain_mapping" "api_auth_domain_mapping" {
  location = var.region
  name     = "www.osposstore.com"

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = var.service_name
  }
}

resource "google_compute_health_check" "api_auth_health_check" {
  name               = "api-auth-health-check"
  check_interval_sec = 15
  timeout_sec        = 5

  http_health_check {
    port_specification = "USE_SERVING_PORT"
    request_path       = "/health"
  }
}

resource "google_compute_url_map" "api_auth_url_map" {
  name            = "api-auth-url-map"
  default_service = google_compute_backend_service.api_auth_backend.id
}

resource "google_compute_target_http_proxy" "api_auth_http_proxy" {
  name    = "api-auth-http-proxy"
  url_map = google_compute_url_map.api_auth_url_map.id
}

resource "google_compute_global_forwarding_rule" "api_auth_forwarding_rule" {
  name                  = "api-auth-forwarding-rule"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.api_auth_http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.api_auth_ip.address
}
