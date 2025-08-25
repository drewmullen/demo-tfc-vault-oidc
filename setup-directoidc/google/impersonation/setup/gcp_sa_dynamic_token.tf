data "tfe_project" "oidc_direct" {
  name         = "tfe-gcp-oidc"
  organization = "mullen-hashi"
}

data "google_project" "project" {}

data "google_iam_workload_identity_pool" "tfc_pool" {
  workload_identity_pool_id = "tfc-pool-demo"
}

resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  workload_identity_pool_id          = data.google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "tfc-provider-impersonation"
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
  
  attribute_condition = "attribute.terraform_organization_name == 'mullen-hashi'"

  # attribute_condition = join(" ", [
  #   "attribute.terraform_organization_id == \"mullen-hashi\" &&",
  #   "attribute.terraform_project_name == \"tfe-gcp-oidc\""
  # ])
}

# is this the audience? audience is the caller
resource "google_service_account_iam_binding" "tfc_binding" {
  service_account_id = google_service_account.doppelganger.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    join("/", [
      "principalSet://iam.googleapis.com/projects", data.google_project.project.number,
      "locations/global/workloadIdentityPools", data.google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id,
      "attribute.terraform_workspace_name", tfe_workspace.dynamic_oidc_impersonation.name
    ]) 
  ]
}

##########################################
# TFE Variable Set and Variables for GCP OIDC Integration
##########################################


resource "tfe_workspace" "dynamic_oidc_impersonation" {
  project_id = data.tfe_project.oidc_direct.id
  name       = "gcp-oidc-impersonation-dynamic"
}

resource "tfe_variable" "gcp_oidc_dynamic" {
  workspace_id = tfe_workspace.dynamic_oidc_impersonation.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "The Vault namespace the runs will use to authenticate."
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.dynamic_oidc_impersonation.id
  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.doppelganger.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.dynamic_oidc_impersonation.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}