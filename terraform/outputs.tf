output "postgres_private_ip" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}

output "api_auth_static_ip" {
  value = google_compute_global_address.api_auth_ip.address
}