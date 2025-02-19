variable "project_id" {
  type = string
  default = "peppy-strategy-450006-a7"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "postgres_instance" {
  type    = string
  default = "postgresql-17"
}

variable "account_id" {
  type    = string
  default = "cloud-build-service-account"
}

variable "postgres_instance_name" {
  type    = string
  default = "postgresql-17"
}


variable "db_name" {
  type    = string
  default = "auth"
}

variable "db_port" {
  type    = string
  default = "5432"
}

variable "db_password_secret_name" {
  type    = string
  default = "db_password"
}

variable "db_user_secret_name" {
  type    = string
  default = "db_user"
}