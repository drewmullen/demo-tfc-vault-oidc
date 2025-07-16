data "google_client_config" "current" {}

output "client_config" {
  value = {
    project     = data.google_client_config.current.project
    region      = data.google_client_config.current.region
    zone        = data.google_client_config.current.zone
  }
}