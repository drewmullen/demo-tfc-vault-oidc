provider "vault" {
  namespace = "admin"
}
variable "org" {
  default = "mullen-hashi"
}
variable "vault_addr" {}
variable "gcp_project_id" {
  description = "The GCP project ID to use for the setup."
  type        = string
  default = "tfc-oidc-464517"
  
}