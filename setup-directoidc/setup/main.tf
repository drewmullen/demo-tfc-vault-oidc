variable "org" {}
variable "gcp_project_id" {}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1" 
}