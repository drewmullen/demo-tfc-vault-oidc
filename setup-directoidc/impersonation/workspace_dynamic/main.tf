terraform {
  cloud {
    organization = "mullen-hashi"

    workspaces {
      # Fetch OIDC token from TFE workspace and use it to authenticate to GCP
      #   for the default provider
      name    = "gcp-oidc-impersonation-dynamic"
      project = "tfe-gcp-oidc"
    }
  }
}

# use default providers credentials to impersonate
provider "google" {
  alias = "ALIAS1"
  impersonate_service_account = "tfc-sa@tfc-oidc-464517.iam.gserviceaccount.com"
}

# use imperstonated provider make a request to GCP
data "google_client_config" "current" {
  provider = google.ALIAS1
}
