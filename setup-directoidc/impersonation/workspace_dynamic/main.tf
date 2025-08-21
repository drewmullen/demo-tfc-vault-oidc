terraform {
  cloud {
    organization = "mullen-hashi"

    workspaces {
      name    = "gcp-oidc-impersonation-dynamic"
      project = "tfe-gcp-oidc"
    }
  }
}

provider "google" {
  credentials = var.tfc_gcp_dynamic_credentials.default.credentials
}

provider "google" {
  alias = "ALIAS1"
  credentials = var.tfc_gcp_dynamic_credentials.default.credentials
  #var.tfc_gcp_dynamic_credentials.aliases["ALIAS1"].credentials
  impersonate_service_account = "tfc-sa@tfc-oidc-464517.iam.gserviceaccount.com"
}

variable "tfc_gcp_dynamic_credentials" {
  description = "Object containing GCP dynamic credentials configuration"
  type = object({
    default = object({
      credentials = string
    })
    aliases = map(object({
      credentials = string
    }))
  })
}





# provider "google" {
#   project = var.gcp_project_id
#   access_token = data.google_service_account_access_token.impersonated_access_token.access_token
#   impersonate_service_account = "tfc-sa@tfc-oidc-464517.iam.gserviceaccount.com"
# }

# Retrieve client configuration (includes project, region, access token, etc.)
data "google_client_config" "current" {
  provider = google.ALIAS1
}

# # Output the project ID and access token
# output "current_project" {
#   value = data.google_client_config.current.project
# }


# data "google_service_account" "account_to_impersonate" {
#   account_id = "tfc-sa"
# }

# # # Provider block for impersonation
# provider "google" {
#   alias        = "impersonated"
#   access_token = data.google_service_account_access_token.impersonated_access_token.access_token
#   project      = var.gcp_project_id
# }

# # Data source to fetch access token for impersonation
# data "google_service_account_access_token" "impersonated_access_token" {
# #   provider               = google
#   target_service_account = data.google_service_account.account_to_impersonate.email
#   scopes                 = ["https://www.googleapis.com/auth/cloud-platform"]
#   lifetime               = "600s"
# }

# data "google_service_account" "impersonated_check" {
#   provider = google.impersonated
#   account_id = "tfc-sa"
# }

# output "impersonated_check" {
#   value = data.google_service_account.impersonated_check.email
# }