resource "tfe_project" "oidc_direct" {
  name         = "demo-tfe-oidc"
  organization = var.org
}

data "google_project" "project" {}

resource "google_iam_workload_identity_pool" "tfc_pool" {
  workload_identity_pool_id = "tfc-pool-demo"
}

resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "tfc-provider"
  oidc {
    issuer_uri = "https://app.terraform.io"
  }
  attribute_mapping = {
    "google.subject"                       = "assertion.sub"
    "attribute.terraform_run_id"            = "assertion.terraform_run_id"
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id"
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name"
    "attribute.terraform_project_id"        = "assertion.terraform_project_id"
    "attribute.terraform_project_name"      = "assertion.terraform_project_name"
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
  }
  # Attribute Conditions restricts authentication to a subset of identities. By default, all identities belonging to providers in this pool can authenticate.  
  attribute_condition = "attribute.terraform_organization_name == '${var.org}'"

#   attribute_condition = join(" ", [
#     "attribute.terraform_organization_id == \"${var.tfc_organization}\" &&",
#     "attribute.terraform_project_name == \"${data.tfe_project.oidc_direct.name}\""
#   ])
}

resource "google_service_account" "tfc_sa" {
  account_id   = "tfc-sa"
  display_name = "Terraform Cloud SA"
}

resource "google_project_iam_member" "tfc_sa_owner" {
  project = var.gcp_project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.tfc_sa.email}"
}

# is this the audience? audience is the caller
resource "google_service_account_iam_binding" "tfc_binding" {
  service_account_id = google_service_account.tfc_sa.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    join("/", [
      "principalSet://iam.googleapis.com/projects", data.google_project.project.number,
      "locations/global/workloadIdentityPools", google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id,
      "attribute.terraform_workspace_name", "test-directoidc"
      # "attribute.terraform_organization_name", var.org,
      # "attribute.terraform_workspace_id", "ws-hQBesPn3huhM8iPw"
    ]) 
  ]
}

##########################################
# TFE Variable Set and Variables for GCP OIDC Integration
##########################################

resource "tfe_variable_set" "gcp_oidc" {
  organization = var.org
  name         = "gcp direct oidc varset"
  description  = "Variables for Direct Workload Identity integration for TFC runs."
}

resource "tfe_project_variable_set" "gcp_oidc" {
  variable_set_id = tfe_variable_set.gcp_oidc.id
  project_id = tfe_project.oidc_direct.id
}

resource "tfe_variable" "gcp_oidc" {
  variable_set_id = tfe_variable_set.gcp_oidc.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "The Vault namespace the runs will use to authenticate."
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  variable_set_id = tfe_variable_set.gcp_oidc.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_sa.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  variable_set_id = tfe_variable_set.gcp_oidc.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}


########################################
# You must also include information about the GCP Workload Identity Provider that HCP Terraform will use when authenticating to GCP. You can supply this information in two different ways:

# By providing one unified variable containing the canonical name of the workload identity provider.
# By providing the project number, pool ID, and provider ID as separate variables.

# resource "tfe_variable" "tfc_gcp_project_number" {
#   variable_set_id = tfe_variable_set.gcp_oidc.id

#   key      = "TFC_GCP_PROJECT_NUMBER"
#   value    = var.gcp_project_id
#   category = "env"
# }


# resource "tfe_variable" "tfc_gcp_pool_id" {
#   variable_set_id = tfe_variable_set.gcp_oidc.id

#   key      = "TFC_GCP_WORKLOAD_POOL_ID"
#   value    = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
#   category = "env"
# }

# resource "tfe_variable" "tfc_gcp_pool_id" {
#   variable_set_id = tfe_variable_set.gcp_oidc.id

#   key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
#   value    = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
#   category = "env"
# }


