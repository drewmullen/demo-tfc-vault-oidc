resource "google_service_account_key" "doppelganger" {
  service_account_id = google_service_account.doppelganger.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "tfe_variable" "gcp_token" {
    workspace_id = tfe_workspace.oidc_impersonation.id
    category     = "terraform" # hack for env
    key          = "GOOGLE_CREDENTIALS"
    value        = base64decode(google_service_account_key.doppelganger.private_key)
}

resource "tfe_workspace" "oidc_impersonation" {
  project_id = data.tfe_project.gcp_oidc.id
  name       = "gcp-oidc-impersonation"
}