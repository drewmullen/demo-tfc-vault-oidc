variable "org" {
  default = "mullen-hashi"
}
variable "gcp_project_id" {
  description = "The GCP project ID to use for the setup."
  type        = string
  default = "tfc-oidc-464517" 
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1" 
}