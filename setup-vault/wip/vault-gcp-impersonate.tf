# resource "google_service_account" "impersonateable" {
#   account_id = "account-to-impersonate"
# }

# resource "vault_gcp_secret_impersonated_account" "impersonated_account" {
#   backend        = vault_gcp_secret_backend.gcp.path

#   impersonated_account  = "impersonate-viewer"
#   service_account_email = google_service_account.impersonateable.email
#   # entire cloud scope
#   token_scopes          = ["https://www.googleapis.com/auth/cloud-platform"]
# }