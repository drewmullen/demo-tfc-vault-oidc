# Define provider for Google Cloud
provider "google" {
  project = var.gcp_project_id
}

# Admin account
data "google_service_account" "account_to_impersonate" {
  account_id = "tfc-sa"
}

# Service account for Terraform execution
resource "google_service_account" "doppelganger" {
  account_id   = "doppelganger"
  display_name = "Doppelganger Service Account"
  description  = "used to show off impersonation"
}

resource "google_service_account_iam_member" "doppelganger_impersonates_tfc_sa" {
  service_account_id = data.google_service_account.account_to_impersonate.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.doppelganger.email}"
}


##### TFC Enablement

provider "tfe" {
  organization = "mullen-hashi" 
}

data "tfe_project" "gcp_oidc" {
  name         = "tfe-gcp-oidc"
  organization = "mullen-hashi"
}