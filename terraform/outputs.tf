output "postgres_private_ip" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}

output "load_balancer_static_ip" {
  value = google_compute_global_address.global_ip.address
}

output "my_current_public_ip" {
  value = data.http.my_ip.response_body
}