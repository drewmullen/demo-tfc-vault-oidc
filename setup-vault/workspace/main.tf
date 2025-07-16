terraform {
  cloud {
    workspaces {
      project = "demo-vault-oidc"
      name = "test"
    }
    organization = "mullen-hashi"
  }
}

data "vault_kv_secret_v2" "test_succeed" {
  mount = "kv"
  name  = "demo-vault-oidc/test/mysecret"
}
