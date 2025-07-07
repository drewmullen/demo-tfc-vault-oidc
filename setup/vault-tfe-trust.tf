resource "tfe_project" "demo" {
  name         = "demo-vault-oidc"
  organization = var.org
}

resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = "jwt-tfc-demo"
  type               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_jwt_auth_backend_role" "vault_admin" {
  backend   = vault_jwt_auth_backend.tfc_jwt.path
  role_name = "app-team"
  token_policies = [
    vault_policy.jwt_based_read.name,
    vault_policy.self.name,
  ]

  bound_audiences = [
    "vault.workload.identity"
  ]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.org}:project:${tfe_project.demo.name}:workspace:*:run_phase:*"
  }

  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 7200

  claim_mappings = {
    # "project_name" = "terraform_project_name"
    # "workspace_name" = "terraform_workspace_name"
    "terraform_project_name" = "project_name" 
    "terraform_workspace_name" = "workspace_name"
  }
}

resource "vault_policy" "jwt_based_read" {
  name = "jwt_based_read"

  policy = <<EOT
path "kv/data/{{identity.entity.metadata.project_name}}/{{identity.entity.metadata.workspace_name}}/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_policy" "self" {
  name = "self"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}
EOT
}

# path "*" {
#   capabilities = ["read", "list", "create", "delete"]
# }
resource "tfe_project_variable_set" "vault_admin_auth_role" {
  variable_set_id = tfe_variable_set.vault_admin.id
  project_id = tfe_project.demo.id
#   name       = "demo-vault-oidc"
#   description = "Variables for Vault Workload Identity integration for TFC runs."
}

resource "tfe_variable_set" "vault_admin" {
  organization = var.org
  name         = tfe_project.demo.name
  description  = "Variables for Vault Workload Identity integration for TFC runs."
}

resource "tfe_variable" "enable_vault_provider_auth" {
  variable_set_id = tfe_variable_set.vault_admin.id

  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "vault" {
  variable_set_id = tfe_variable_set.vault_admin.id

  key      = "TFC_VAULT_NAMESPACE"
  value    = "admin"
  category = "env"

  description = "The Vault namespace the runs will use to authenticate."
}
resource "tfe_variable" "tfc_vault_role" {
  variable_set_id = tfe_variable_set.vault_admin.id

  key      = "TFC_VAULT_RUN_ROLE"
  value    = vault_jwt_auth_backend_role.vault_admin.role_name
  category = "env"

  description = "The Vault role runs will use to authenticate."
}

resource "tfe_variable" "tfc_vault_auth_path" {
  variable_set_id = tfe_variable_set.vault_admin.id

  key      = "TFC_VAULT_AUTH_PATH"
  value    = vault_jwt_auth_backend.tfc_jwt.path
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "tfc_vault_addr" {
  variable_set_id = tfe_variable_set.vault_admin.id

  key       = "TFC_VAULT_ADDR"
  value     = var.vault_addr
  category  = "env"
  sensitive = false

  description = "The address of the Vault instance runs will access."
}
