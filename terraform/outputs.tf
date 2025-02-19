output "postgres_private_ip" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}