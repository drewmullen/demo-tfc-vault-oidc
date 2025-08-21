terraform {
  cloud {
    workspaces {
      project = "demo-tfe-oidc"
      name = "test-directoidc"
    }
    organization = "mullen-hashi"
  }
}

variable "gcp_project_id" {}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
  zone    = "us-central1-a"
}

# data "google_client_config" "current" {}

# output "client_config" {
#   value = {
#     project = data.google_client_config.current.project
#     region  = data.google_client_config.current.region
#     zone    = data.google_client_config.current.zone
#   }
# }

resource "google_service_account" "test" {
  account_id   = "tfc-sa-test"
  display_name = "Terraform Cloud SA"
  project = var.gcp_project_id
}


resource "google_storage_bucket" "test-bucket" {
  project       = var.gcp_project_id
  name          = "${var.gcp_project_id}-test2"
  location      = "US"
  force_destroy = true
}
