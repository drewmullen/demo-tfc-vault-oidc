terraform {
  cloud {
    organization = "mullen-hashi"

    workspaces {
      # Workspace is created and setup to
      #   fetch an OIDC token from TFE workspace 
      #   and use it to authenticate to GCP
      #   for the default provider
      name    = "gcp-oidc-impersonation-dynamic"
      project = "tfe-gcp-oidc"
    }
  }
}
