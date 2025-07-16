resource "vault_gcp_secret_backend" "gcp" {
  credentials       = file("creds.json")
  rotation_schedule = "0 * * * SAT"
  rotation_window   = 3600
}

# vault_gcp_secret_impersonation_role
resource "vault_gcp_secret_roleset" "roleset" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_viewer"
  secret_type  = "access_token"
  project      = var.gcp_project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/tfc-oidc-464517"

    roles = [
      "roles/viewer",
    ]
  }
}

resource "tfe_variable_set" "gcp" {
  organization = var.org
  name         = "gcp varset"
  description  = "Variables for Vault Workload Identity integration for TFC runs."
}


resource "tfe_project_variable_set" "gcp" {
  variable_set_id = tfe_variable_set.gcp.id
  project_id = tfe_project.demo.id
}

resource "tfe_variable" "gcp_auth" {
  variable_set_id = tfe_variable_set.gcp.id

  key      = "TFC_VAULT_BACKED_GCP_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "gcp_auth_type" {
  variable_set_id = tfe_variable_set.gcp.id

  key      = "TFC_VAULT_BACKED_GCP_AUTH_TYPE"
  value    = "roleset/access_token"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}
//

resource "tfe_variable" "gcp_roleset" {
  variable_set_id = tfe_variable_set.gcp.id

  key      = "TFC_VAULT_BACKED_GCP_RUN_VAULT_ROLESET"
  value    = "project_viewer" #vault_gcp_secret_roleset.roleset.id
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}